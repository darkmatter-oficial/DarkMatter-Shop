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
const adminNumber = "573001125554"; // Tu número configurado

async function iniciarBot() {
    const { state, saveCreds } = await useMultiFileAuthState('sesion_bot');
    const { version } = await fetchLatestBaileysVersion();

        const sock = makeWASocket({
        version,
        logger: pino({ level: 'silent' }),
        auth: state,
        browser: ["Ubuntu", "Chrome", "20.0.04"], 
    });

    // === CÓDIGO DE VINCULACIÓN ===
    if (!sock.authState.creds.registered) {
        setTimeout(async () => {
            let code = await sock.requestPairingCode(adminNumber);
            code = code?.match(/.{1,4}/g)?.join("-") || code;
            console.log(`\n\n⭐ TU CÓDIGO DE VINCULACIÓN ES: ${code} ⭐\n\n`);
        }, 3000);
    }

    sock.ev.on('creds.update', saveCreds);

    sock.ev.on('connection.update', (update) => {
        const { connection } = update;
        if (connection === 'close') iniciarBot();
        else if (connection === 'open') console.log("\n🚀 DARKMATTER CONECTADO");
    });

    sock.ev.on('messages.upsert', async m => {
        const msg = m.messages[0];
        
        // --- FILTRO ANTI-SPAM DEFINITIVO ---
        if (!msg.message || msg.key.fromMe) return; 

        const from = msg.key.remoteJid;
        
        // Si el mensaje viene de tu propio número, el bot no debe responder para evitar bucles
        if (from.includes(adminNumber)) return;

        const safeId = from.replace(/[^a-zA-Z0-9]/g, '');
        const text = (msg.message.conversation || msg.message.extendedTextMessage?.text || "").trim();
        const textLow = text.toLowerCase();

        // VALIDACIÓN DE SESIÓN PERSISTENTE
        const sessionRef = db.ref(`sesiones_whatsapp/${safeId}`);
        const sessionSnap = await sessionRef.once('value');
        const userData = sessionSnap.val();

        // COMANDO PRINCIPAL
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
                    return await sock.sendMessage(from, { text: `🔎 *IDENTIDAD DETECTADA*\n\nHe encontrado el correo: *${correoVinculado}* vinculado a este número.\n\n¿Eres tú?\n1. Sí\n2. No` });
                }

                tempState[from] = { step: 'LOGIN_EMAIL' };
                return await sock.sendMessage(from, { text: '🔑 *DARKMATTER LOGIN*\n\nIngresa tu *Correo* vinculado:' });
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

        // --- LÓGICA DE ESTADOS ---
        const step = tempState[from];

        if (step && step.step === 'PRIVATE_MODE') return;

        // Si no hay comando y no hay estado activo, preguntamos
        if (!step && textLow !== '/darkmatter') {
            const bienvenidaMsg = `🌌 *DARKMATTER ASSISTANT* 🌌\n\n` +
                                 `¿Deseas usar el *Bot Automático* o hablar con la *Persona* encargada?\n\n` +
                                 `🟢 Responde *SÍ* para el Bot.\n` +
                                 `🔴 Responde *NO* para chat privado.`;
            
            tempState[from] = { step: 'ASK_BOT_OR_HUMAN' };
            return await sock.sendMessage(from, { text: bienvenidaMsg });
        }

        if (step) {
            if (step.step === 'ASK_BOT_OR_HUMAN') {
                if (textLow === 'si' || textLow === 'sí') {
                    delete tempState[from];
                    return await sock.sendMessage(from, { text: `✅ *MODO BOT ACTIVADO*\n\nEscribe */DarkMatter* para comenzar.` });
                } else if (textLow === 'no') {
                    tempState[from] = { step: 'PRIVATE_MODE' };
                    return await sock.sendMessage(from, { text: `👤 *MODO PRIVADO ACTIVADO*\n\nEl bot se ha desactivado para este chat. Escribe */DarkMatter* si lo necesitas de nuevo.` });
                } else {
                    return await sock.sendMessage(from, { text: `⚠️ Responde *SÍ* o *NO*.` });
                }
            }
            
            if (step.step === 'CONFIRM_EMAIL') {
                if (text === '1') {
                    step.step = 'LOGIN_PASS';
                    await sock.sendMessage(from, { text: `🔐 Ingresa la contraseña para: *${step.email}*` });
                } else {
                    step.step = 'LOGIN_EMAIL';
                    await sock.sendMessage(from, { text: '📧 Ingresa tu correo:' });
                }
                return;
            }

            if (step.step === 'LOGIN_EMAIL') {
                step.email = textLow;
                step.step = 'LOGIN_PASS';
                await sock.sendMessage(from, { text: '🔐 Ingresa tu contraseña:' });
                return;
            }

            if (step.step === 'LOGIN_PASS') {
                const pass = text;
                await sock.sendMessage(from, { text: '⏳ Validando...' });
                const authRef = db.ref('usuarios_auth');
                authRef.once('value', async (snap) => {
                    const users = snap.val() || {};
                    let userFound = null;
                    for (let u in users) {
                        if (u.replace(/_/g, '.') === step.email && users[u].password === pass) {
                            userFound = users[u];
                            break;
                        }
                    }
                    if (userFound) {
                        await sessionRef.set({ email: step.email, pass: pass });
                        await sock.sendMessage(from, { text: '✅ *Login Exitoso*' });
                    } else {
                        await sock.sendMessage(from, { text: '❌ Error en los datos.' });
                    }
                    delete tempState[from];
                });
                return;
            }

            if (step.step === 'CONSULTA_KEY') {
                const keyInput = text;
                const ref = db.ref(`keys/${keyInput}`);
                ref.once('value', async (snapshot) => {
                    const data = snapshot.val();
                    if (data && data.correo && data.correo.toLowerCase() === userData.email) {
                        const res = `✅ *KEY:* ${keyInput}\n👤 *User:* ${data.nombreRoblox}\n📅 *Expira:* ${data.expira}`;
                        await sock.sendMessage(from, { text: res });
                    } else {
                        await sock.sendMessage(from, { text: '❌ Key inválida.' });
                    }
                    delete tempState[from];
                });
                return;
            }
        }

        // OPCIONES DEL MENÚ
        if (text === '1') {
            const statusRef = db.ref('Valores del panel');
            statusRef.once('value', async (snapshot) => {
                const v = snapshot.val() || {};
                const msgS = `📊 *SISTEMA:* ${v.Estado || 'Activo'}\n📡 *Versión:* 4.5 Stable`;
                await sock.sendMessage(from, { text: msgS });
            });
        }
        
        if (text === '3') {
            await sock.sendMessage(from, { text: `🛠 *SOPORTE:* wa.me/${adminNumber}` });
        }

        if (text === '4') {
            await sock.sendMessage(from, { text: `🎁 *KEY GRATIS:* https://linkvertise.com/5116981/FIGf3YGXqNhz` });
        }

        if (text === '5') {
            if (userData) {
                await sessionRef.remove();
                await sock.sendMessage(from, { text: '🚪 Sesión cerrada.' });
            }
        }

        if (text === '2') {
            if (!userData) return await sock.sendMessage(from, { text: '❌ Usa /darkmatter' });
            tempState[from] = { step: 'CONSULTA_KEY' };
            await sock.sendMessage(from, { text: '🔍 Ingresa la Key:' });
        }
    });
}
iniciarBot();
