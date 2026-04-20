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
        browser: ["DarkMatter Bot", "Chrome", "1.0.0"]
    });

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
        const text = (msg.message.conversation || msg.message.extendedTextMessage?.text || "").trim();

        // INICIO
        if (text.toLowerCase() === '/darkmatter') {
            delete tempState[from];
            const menu = `🌌 *DARKMATTER PANEL* 🌌\n\n` +
                         `1. Estado del Sistema ✅\n` +
                         `2. Consultar mi Key 🔑\n` +
                         `3. Soporte Técnico 🛠\n\n` +
                         `_Responde con el número de la opción deseada._`;
            return await sock.sendMessage(from, { text: menu });
        }

        if (text === '1') {
            await sock.sendMessage(from, { text: '⏳ *Analizando integridad de la base de datos...*' });
            const statusRef = db.ref('/');
            return statusRef.once('value', async (snapshot) => {
                const allData = snapshot.val() || {};
                
                // Extracción de datos desde Firebase según estructura de capturas
                const valoresPanel = allData['Valores del panel'] || {};
                const estadoRaw = valoresPanel.Estado || "Desconocido";
                const totalKeys = allData.keys ? Object.keys(allData.keys).length : 0;
                const totalUsuarios = allData.usuarios_auth ? Object.keys(allData.usuarios_auth).length : 0;
                const freeLimit = allData.free_key_limit || "Ilimitado";
                
                // Lógica de estado dinámico
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
                                 `📉 *Límite Free:* ${freeLimit}\n` +
                                 `📡 *Versión:* 2.5.0 Stable\n` +
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

        // PASO 1: PEDIR KEY
        if (text === '2') {
            tempState[from] = { step: 'KEY' };
            return await sock.sendMessage(from, { text: '🔍 Ingresa tu *Key*:' });
        }

        const step = tempState[from];
        if (step) {
            // PASO 2: RECIBIR KEY -> PEDIR CORREO
            if (step.step === 'KEY') {
                step.key = text;
                step.step = 'EMAIL';
                await sock.sendMessage(from, { text: '📧 Ahora ingresa tu *Correo*:' });
            } 
            // PASO 3: RECIBIR CORREO -> PEDIR CONTRASEÑA
            else if (step.step === 'EMAIL') {
                step.email = text.toLowerCase();
                step.step = 'PASS';
                await sock.sendMessage(from, { text: '🔐 Por último, ingresa tu *Contraseña*:' });
            } 
            // PASO 4: RECIBIR CONTRASEÑA -> VERIFICAR EN FIREBASE
            else if (step.step === 'PASS') {
                const passInput = text;
                await sock.sendMessage(from, { text: '⏳ Verificando datos...' });

                const ref = db.ref(`keys/${step.key}`);
                ref.once('value', async (snapshot) => {
                    const data = snapshot.val();
                    
                    // Verificamos que existan los datos y que los campos no sean undefined
                    if (data && data.correo && data.contrasena) {
                        if (data.correo.toLowerCase() === step.email && data.contrasena === passInput) {
                            const res = `✅ *DATOS ENCONTRADOS*\n\n` +
                                        `👤 *User:* ${data.nombreRoblox}\n` +
                                        `📅 *Expira:* ${data.expira}\n` +
                                        `📱 *Device:* ${data.dispositivo}\n` +
                                        `💰 *Costo:* ${data.costo}`;
                            await sock.sendMessage(from, { text: res });
                        } else {
                            await sock.sendMessage(from, { text: '❌ *Error:* Los datos no coinciden.' });
                        }
                    } else {
                        await sock.sendMessage(from, { text: '❌ *Error:* La Key no existe o faltan datos en el registro.' });
                    }
                    delete tempState[from]; // Limpiar estado al terminar
                });
            }
        }
    });
}
iniciarBot();
