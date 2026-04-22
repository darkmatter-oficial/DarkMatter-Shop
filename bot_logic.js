const { default: makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion } = require("@whiskeysockets/baileys");
const pino = require("pino");
const admin = require("firebase-admin");

// CONFIGURACIÓN FIREBASE
const serviceAccount = require("./serviceAccount.json");
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://key-sistem-roblox-dm-default-rtdb.firebaseio.com"
    });
}
const db = admin.database();

let tempState = {}; 

async function iniciarBot() {
    const { state, saveCreds } = await useMultiFileAuthState('sesion_bot');
    const { version } = await fetchLatestBaileysVersion();

        const sock = makeWASocket({
        version,
        logger: pino({ level: 'silent' }),
        auth: state,
        browser: ["Ubuntu", "Chrome", "20.0.04"], 
    });

    // === AGREGA ESTO PARA EL CÓDIGO DE VINCULACIÓN ===
    if (!sock.authState.creds.registered) {
        const phoneNumber = "573001125554"; 
        setTimeout(async () => {
            let code = await sock.requestPairingCode(phoneNumber);
            code = code?.match(/.{1,4}/g)?.join("-") || code;
            console.log(`\n\n⭐ TU CÓDIGO DE VINCULACIÓN ES: ${code} ⭐\n\n`);
        }, 3000);
    }
    // ===============================================

    sock.ev.on('creds.update', saveCreds);

    sock.ev.on('connection.update', (update) => {
        const { connection } = update;
        if (connection === 'close') iniciarBot();
        else if (connection === 'open') console.log("\n🚀 DARKMATTER CONECTADO");
    });

    sock.ev.on('messages.upsert', async m => {
        const msg = m.messages[0];
        
        // --- PROTECCIÓN ANTI-BUCLE ---
        // Si el mensaje no tiene contenido, es de un grupo o es enviado por el mismo bot, ignoramos.
        if (!msg.message || msg.key.fromMe) return;

        const from = msg.key.remoteJid;
        const safeId = from.replace(/[^a-zA-Z0-9]/g, '');
        const text = (msg.message.conversation || msg.message.extendedTextMessage?.text || "").trim();
        const textLow = text.toLowerCase();

        // VALIDACIÓN DE SESIÓN PERSISTENTE
        const sessionRef = db.ref(`sesiones_whatsapp/${safeId}`);
        const sessionSnap = await sessionRef.once('value');
        const userData = sessionSnap.val();

        // INICIO COMANDO PRINCIPAL
        if (textLow === '/darkmatter') {
            delete tempState[from];
            
            if (!userData) {
                const keysRef = db.ref('keys');
                const keysSnap = await keysRef.once('value');
                const allKeys = keysSnap.val() || {};
                let correoVinculado = null;
                const numeroLimpio = from.split('@')[0];

                for (let id in allKeys) {
                    if (allKeys[id].telefono === numeroLimpio) {
                        correoVinculado = allKeys[id].correo;
                        break;
                    }
                }

                if (correoVinculado) {
                    tempState[from] = { step: 'CONFIRM_EMAIL', email: correoVinculado.toLowerCase() };
                    return await sock.sendMessage(from, { text: `🔎 *IDENTIDAD DETECTADA*\n\nHe encontrado el correo: *${correoVinculado}* vinculado a este número.\n\n¿Eres tú?\n1. Sí\n2. No (Usar otro correo)` });
                }

                tempState[from] = { step: 'LOGIN_EMAIL' };
                return await sock.sendMessage(from, { text: '🔑 *DARKMATTER LOGIN*\n\nNo detecto una sesión activa para este número.\n\nPor favor, ingresa tu *Correo* vinculado:' });
            }

            const menu = `🌌 *DARKMATTER PANEL* 🌌\n\n` +
                         `Bienvenido: ${userData.email}\n\n` +
                         `1. Estado del Sistema ✅\n` +
                         `2. Consultar mi Key 🔑\n` +
                         `3. Soporte Técnico 🛠\n` +
                         `4. Obtener Key Gratis (2h) 🎁\n` +
                         `5. Cerrar Sesión 🚪\n\n` +
                         `_Responde con el número de la opción deseada._`;
            return await sock.sendMessage(from, { text: menu });
        }

        // --- LÓGICA DE ESTADOS (tempState) ---
        const step = tempState[from];

        // Si ya está en modo privado, el bot no responde nada a menos que use /darkmatter
        if (step && step.step === 'PRIVATE_MODE') {
            return;
        }

        // Si no hay comando y no hay un estado activo de pregunta, lanzamos la pregunta inicial
        if (!step && textLow !== '/darkmatter') {
            const bienvenidaMsg = `🌌 *DARKMATTER ASSISTANT* 🌌\n\n` +
                                 `¡Hola! He detectado que estás intentando comunicarte.\n\n` +
                                 `¿Deseas usar el *Bot Automático* de la tienda DarkMatter o prefieres hablar directamente con la *Persona* encargada de este número?\n\n` +
                                 `🟢 Responde *SÍ* para usar el Bot.\n` +
                                 `🔴 Responde *NO* para hablar en privado con el administrador.`;
            
            tempState[from] = { step: 'ASK_BOT_OR_HUMAN' };
            return await sock.sendMessage(from, { text: bienvenidaMsg });
        }

        if (step) {
            // Lógica de elección: Bot o Humano
            if (step.step === 'ASK_BOT_OR_HUMAN') {
                if (textLow === 'si' || textLow === 'sí') {
                    delete tempState[from];
                    return await sock.sendMessage(from, { text: `✅ *MODO BOT ACTIVADO*\n\nEscribe el comando 👉 */DarkMatter* para comenzar.` });
                } else if (textLow === 'no') {
                    tempState[from] = { step: 'PRIVATE_MODE' };
                    return await sock.sendMessage(from, { text: `👤 *MODO PRIVADO ACTIVADO*\n\nAhora estás hablando directamente con el administrador. El bot se mantendrá desactivado.\n\nEscribe */DarkMatter* en cualquier momento para volver a usar el bot.` });
                } else {
                    // Si escribe cualquier otra cosa mientras la pregunta está activa
                    return await sock.sendMessage(from, { text: `⚠️ *POR FAVOR RESPONDE*\n\n¿Quieres usar el bot o hablar con la persona?\n\nResponde *SÍ* o *NO*.` });
                }
            }
            
            // LÓGICA DE CONFIRMACIÓN DE CORREO
            if (step.step === 'CONFIRM_EMAIL') {
                if (text === '1') {
                    step.step = 'LOGIN_PASS';
                    await sock.sendMessage(from, { text: `🔐 Perfecto. Ingresa la *Contraseña* para: *${step.email}*` });
                } else {
                    step.step = 'LOGIN_EMAIL';
                    await sock.sendMessage(from, { text: '📧 Ingresa el *Correo* que deseas usar:' });
                }
                return;
            }

            // LOGIN EMAIL
            if (step.step === 'LOGIN_EMAIL') {
                step.email = textLow;
                step.step = 'LOGIN_PASS';
                await sock.sendMessage(from, { text: '🔐 Ahora ingresa tu *Contraseña*:' });
                return;
            }

            // LOGIN PASS
            if (step.step === 'LOGIN_PASS') {
                const pass = text;
                await sock.sendMessage(from, { text: '⏳ Validando credenciales...' });
                const authRef = db.ref('usuarios_auth');
                authRef.once('value', async (snap) => {
                    const users = snap.val() || {};
                    let userFound = null;
                    for (let u in users) {
                        const emailLimpio = u.replace(/_/g, '.');
                        if (emailLimpio === step.email && users[u].password === pass) {
                            userFound = users[u];
                            break;
                        }
                    }
                    if (userFound) {
                        await sessionRef.set({ email: step.email, pass: pass });
                        await sock.sendMessage(from, { text: '✅ *Login Exitoso*\n\nEscribe /darkmatter para ver el menú.' });
                    } else {
                        await sock.sendMessage(from, { text: '❌ Credenciales incorrectas.' });
                    }
                    delete tempState[from];
                });
                return;
            }

            // CONSULTA DE KEY
            if (step.step === 'CONSULTA_KEY') {
                const keyInput = text;
                await sock.sendMessage(from, { text: '⏳ Verificando propiedad...' });
                const ref = db.ref(`keys/${keyInput}`);
                ref.once('value', async (snapshot) => {
                    const data = snapshot.val();
                    if (data && data.correo && data.correo.toLowerCase() === userData.email) {
                        const res = `✅ *DATOS DE TU KEY*\n\n👤 *User:* ${data.nombreRoblox}\n📅 *Expira:* ${data.expira}\n📱 *Device:* ${data.dispositivo}\n💰 *Costo:* ${data.costo}`;
                        await sock.sendMessage(from, { text: res });
                    } else {
                        await sock.sendMessage(from, { text: '❌ Error: Key inexistente o no te pertenece.' });
                    }
                    delete tempState[from];
                });
                return;
            }
        }

        // MENÚ DE OPCIONES NUMÉRICAS
        if (text === '1') {
            await sock.sendMessage(from, { text: '⏳ *Analizando sistema...*' });
            const statusRef = db.ref('/');
            statusRef.once('value', async (snapshot) => {
                const allData = snapshot.val() || {};
                const valoresPanel = allData['Valores del panel'] || {};
                const estadoRaw = valoresPanel.Estado || "Desconocido";
                const totalKeys = allData.keys ? Object.keys(allData.keys).length : 0;
                const totalUsuarios = allData.usuarios_auth ? Object.keys(allData.usuarios_auth).length : 0;
                
                let limiteGratis = "Disponible";
                if (userData && userData.email) {
                    const hoy = new Date().toLocaleString("es-CO", {timeZone: "America/Bogota"}).split(',')[0].replace(/\//g, '-');
                    const freeKeys = allData.keys || {};
                    for (let id in freeKeys) {
                        if (freeKeys[id].correo === userData.email && freeKeys[id].dispositivo === "DARKMATTER UNIVERSAL" && freeKeys[id].expira && freeKeys[id].expira.includes(hoy)) {
                            limiteGratis = "Agotado";
                            break;
                        }
                    }
                }
                
                const estadoSistema = estadoRaw.toLowerCase() === "mantenimiento" ? "⚠️ *MANTENIMIENTO*" : "🟢 *ACTIVO*";
                const statusMsg = `📊 *ESTADO GLOBAL*\n\n🖥️ *Panel:* ${estadoSistema}\n🔑 *Keys:* ${totalKeys}\n👥 *Usuarios:* ${totalUsuarios}\n📉 *Límite Gratis:* ${limiteGratis}\n📡 *Versión:* 4.5 Stable`;
                await sock.sendMessage(from, { text: statusMsg });
            });
        }
        
        if (text === '3') {
            const supportMsg = `🛠 *SOPORTE TÉCNICO*\n\n👑 *Admin:* Sergio\n💬 *WhatsApp:* wa.me/573001125554\n📌 *ID:* #${Math.floor(Math.random() * 9000) + 1000}`;
            await sock.sendMessage(from, { text: supportMsg });
        }

        if (text === '4') {
            const keysRef = db.ref('keys');
            keysRef.once('value', async (snapshot) => {
                const keys = snapshot.val() || {};
                let keyGratisEncontrada = null;
                if (userData) {
                    for (let id in keys) {
                        if (keys[id].correo === userData.email && keys[id].dispositivo === "DARKMATTER UNIVERSAL") {
                            keyGratisEncontrada = { id, ...keys[id] };
                            break;
                        }
                    }
                }
                let msgGratis = `🎁 *KEYS GRATIS*\n\n🔗 https://linkvertise.com/5116981/FIGf3YGXqNhz\n\n`;
                if (keyGratisEncontrada) msgGratis += `🔑 *Tu Key:* ${keyGratisEncontrada.id}\n⏳ *Expira:* ${keyGratisEncontrada.expira}`;
                await sock.sendMessage(from, { text: msgGratis });
            });
        }

        if (text === '5') {
            if (!userData) return;
            await sessionRef.remove();
            await sock.sendMessage(from, { text: '🚪 *SESIÓN CERRADA*' });
        }

        if (text === '2') {
            if (!userData) return await sock.sendMessage(from, { text: '❌ Inicia sesión con /darkmatter' });
            tempState[from] = { step: 'CONSULTA_KEY' };
            await sock.sendMessage(from, { text: '🔍 Ingresa la *Key* a consultar:' });
        }
    });
}
iniciarBot();
