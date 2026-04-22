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
        browser: ["Ubuntu", "Chrome", "20.0.04"], // Cambié esto para que WhatsApp lo acepte mejor
    });

    // === AGREGA ESTO PARA EL CÓDIGO DE VINCULACIÓN ===
    if (!sock.authState.creds.registered) {
        const phoneNumber = "573001125554"; // <--- PON AQUÍ TU NÚMERO CON CÓDIGO DE PAÍS
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
        if (!msg.message || msg.key.fromMe) return;

        const from = msg.key.remoteJid;
        // Limpiamos el ID para evitar errores de ruta en Firebase (quitamos @s.whatsapp.net y puntos)
        const safeId = from.replace(/[^a-zA-Z0-9]/g, '');

        const text = (msg.message.conversation || msg.message.extendedTextMessage?.text || "").trim();

        // VALIDACIÓN DE SESIÓN PERSISTENTE
        const sessionRef = db.ref(`sesiones_whatsapp/${safeId}`);
        const sessionSnap = await sessionRef.once('value');
        const userData = sessionSnap.val();

        // INICIO
        if (text.toLowerCase() === '/darkmatter') {
            delete tempState[from];
            
            if (!userData) {
                // Buscar si existe alguna key vinculada a este número de teléfono
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

        // --- LÓGICA DE DETECCIÓN DE MENSAJES SIN COMANDO ---
        if (!tempState[from] && text.toLowerCase() !== '/darkmatter') {
            const bienvenidaMsg = `🌌 *DARKMATTER ASSISTANT* 🌌\n\n` +
                                 `¡Hola! He detectado que estás intentando comunicarte.\n\n` +
                                 `¿Deseas usar el *Bot Automático* de la tienda DarkMatter o prefieres hablar directamente con la *Persona* encargada de este número?\n\n` +
                                 `🟢 Responde *SÍ* para usar el Bot.\n` +
                                 `🔴 Responde *NO* para hablar en privado con el administrador.`;
            
            tempState[from] = { step: 'ASK_BOT_OR_HUMAN' };
            return await sock.sendMessage(from, { text: bienvenidaMsg });
        }

        const step = tempState[from];
        if (step) {
            // Lógica de elección entre Bot o Humano
            if (step.step === 'ASK_BOT_OR_HUMAN') {
                if (text.toLowerCase() === 'si' || text.toLowerCase() === 'sí') {
                    delete tempState[from];
                    return await sock.sendMessage(from, { text: `✅ *MODO BOT ACTIVADO*\n\nPara acceder a nuestros servicios y soporte automático, por favor escribe el comando:\n\n👉 */DarkMatter*` });
                } else if (text.toLowerCase() === 'no') {
                    delete tempState[from];
                    return await sock.sendMessage(from, { text: `👤 *MODO PRIVADO ACTIVADO*\n\nAhora estás en modo de chat directo con el dueño del número. Si en algún momento deseas consultar la tienda o tus productos, solo escribe */DarkMatter* para activar el bot.` });
                } else {
                    return await sock.sendMessage(from, { text: `⚠️ *POR FAVOR RESPONDE*\n\n¿Quieres hablar con la persona que dirige este número o deseas usar el bot de la tienda DarkMatter?\n\nResponde *SÍ* (Bot) o *NO* (Persona).` });
                }
            }
            
            // LÓGICA DE CONFIRMACIÓN DE CORREO POR NÚMERO
            if (step.step === 'CONFIRM_EMAIL') {
                if (text === '1') {
                    step.step = 'LOGIN_PASS';
                    await sock.sendMessage(from, { text: `🔐 Perfecto. Ingresa la *Contraseña* para la cuenta: *${step.email}*` });
                } else {
                    step.step = 'LOGIN_EMAIL';
                    await sock.sendMessage(from, { text: '📧 Entendido. Ingresa el *Correo* que deseas usar:' });
                }
            }
            // LÓGICA DE LOGIN PRIMERIZO
            else if (step.step === 'LOGIN_EMAIL') {
                step.email = text.toLowerCase();
                step.step = 'LOGIN_PASS';
                await sock.sendMessage(from, { text: '🔐 Ahora ingresa tu *Contraseña* de DarkMatter:' });
            }
            else if (step.step === 'LOGIN_PASS') {
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
                        await sock.sendMessage(from, { text: '✅ *Login Exitoso*\n\nSesión vinculada a tu número. Escribe /darkmatter para ver el menú.' });
                    } else {
                        await sock.sendMessage(from, { text: '❌ Correo o contraseña incorrectos.' });
                    }
                    delete tempState[from];
                });
            }
            // CONSULTA DE KEY CON DATOS AUTOMÁTICOS
            else if (step.step === 'CONSULTA_KEY') {
                const keyInput = text;
                await sock.sendMessage(from, { text: '⏳ Verificando propiedad de la key...' });

                const ref = db.ref(`keys/${keyInput}`);
                ref.once('value', async (snapshot) => {
                    const data = snapshot.val();
                    if (data && data.correo && data.correo.toLowerCase() === userData.email) {
                        const res = `✅ *DATOS DE TU KEY*\n\n` +
                                    `👤 *User:* ${data.nombreRoblox}\n` +
                                    `📅 *Expira:* ${data.expira}\n` +
                                    `📱 *Device:* ${data.dispositivo}\n` +
                                    `💰 *Costo:* ${data.costo}`;
                        await sock.sendMessage(from, { text: res });
                    } else {
                        await sock.sendMessage(from, { text: '❌ *Error:* La key no existe o no te pertenece.' });
                    }
                    delete tempState[from];
                });
            }
        }

        if (text === '1') {
            await sock.sendMessage(from, { text: '⏳ *Analizando integridad de la base de datos...*' });
            const statusRef = db.ref('/');
            return statusRef.once('value', async (snapshot) => {
                const allData = snapshot.val() || {};
                
                const valoresPanel = allData['Valores del panel'] || {};
                const estadoRaw = valoresPanel.Estado || "Desconocido";
                const totalKeys = allData.keys ? Object.keys(allData.keys).length : 0;
                const totalUsuarios = allData.usuarios_auth ? Object.keys(allData.usuarios_auth).length : 0;
                
                // LÓGICA DE LÍMITE GRATIS (Verificación de canje diario)
                let limiteGratis = "Disponible";
                if (userData && userData.email) {
                    const hoy = new Date().toLocaleString("es-CO", {timeZone: "America/Bogota"}).split(',')[0].replace(/\//g, '-');
                    const freeKeys = allData.keys || {};
                    for (let id in freeKeys) {
                        if (freeKeys[id].correo === userData.email && 
                            freeKeys[id].dispositivo === "DARKMATTER UNIVERSAL" && 
                            freeKeys[id].expira && freeKeys[id].expira.includes(hoy)) {
                            limiteGratis = "Agotado";
                            break;
                        }
                    }
                }
                
                let estadoSistema;
                if (estadoRaw.toLowerCase() === "mantenimiento") {
                    estadoSistema = "⚠️ *MANTENIMIENTO*";
                } else {
                    estadoSistema = "🟢 *ACTIVO*";
                }

                const statusMsg = `📊 *ESTADO GLOBAL DEL SISTEMA*\n\n` +
                                 `🖥️ *Panel:* ${estadoSistema}\n` +
                                 `🟢 *Servidor:* Operativo (Termux Node.js)\n` +
                                 `🗄️ *Base de Datos:* Firebase RTDB Online\n` +
                                 `🔑 *Keys Activas:* ${totalKeys}\n` +
                                 `👥 *Usuarios Registrados:* ${totalUsuarios}\n` +
                                 `📉 *Límite Gratis:* ${limiteGratis}\n` +
                                 `📡 *Versión:* 4.5 Stable\n` +
                                 `⏱️ *Latencia:* Estable (Sincronizada)\n\n` +
                                 `_Información obtenida en tiempo real desde el servidor central._`;
                await sock.sendMessage(from, { text: statusMsg });
            });
        }
        
        if (text === '3') {
            await sock.sendMessage(from, { text: '🛠 *Obteniendo información del administrador...*' });
            const supportRef = db.ref('Valores del panel');
            return supportRef.once('value', async (snapshot) => {
                const supportData = snapshot.val() || {};
                const supportMsg = `🛠 *CENTRO DE SOPORTE TÉCNICO*\n\n` +
                                  `Has solicitado asistencia técnica para DarkMatter Panel.\n\n` +
                                  `👑 *Admin:* Sergio\n` +
                                  `💬 *WhatsApp:* wa.me/573001125554\n` +
                                  `📌 *ID Soporte:* #${Math.floor(Math.random() * 9000) + 1000}\n\n` +
                                  `_Por favor, envía un mensaje al administrador con tu captura de pantalla y el ID de soporte generado._`;
                await sock.sendMessage(from, { text: supportMsg });
            });
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

                let msgGratis = `🎁 *SISTEMA DE KEYS GRATUITAS*\n\n` +
                                `Puedes obtener una key de 2 horas aquí:\n` +
                                `🔗 https://linkvertise.com/5116981/FIGf3YGXqNhz?o=sharing\n\n`;

                if (keyGratisEncontrada) {
                    msgGratis += `🔑 *Tu Key Actual:* ${keyGratisEncontrada.id}\n` +
                                 `⏳ *Expira:* ${keyGratisEncontrada.expira}`;
                } else {
                    msgGratis += `_No tienes ninguna key universal activa vinculada a tu correo._`;
                }
                
                await sock.sendMessage(from, { text: msgGratis });
            });
            return;
        }

        // OPCIÓN 5: CERRAR SESIÓN
        if (text === '5') {
            if (!userData) return;
            await sessionRef.remove();
            return await sock.sendMessage(from, { text: '🚪 *SESIÓN CERRADA*\n\nTu cuenta ha sido desvinculada de este número exitosamente.' });
        }

        // PASO 1: PEDIR KEY (CON AUTOLOGIN)
        if (text === '2') {
            if (!userData) return await sock.sendMessage(from, { text: '❌ Debes iniciar sesión con /darkmatter primero.' });
            tempState[from] = { step: 'CONSULTA_KEY' };
            return await sock.sendMessage(from, { text: '🔍 Ingresa la *Key* que deseas consultar:' });
        }
    });
}
iniciarBot();
