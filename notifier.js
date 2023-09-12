const { Telegraf } = require('telegraf');
const exec = require('child_process').exec;

const bot = new Telegraf('token');

bot.on('callback_query', (ctx) => {
  const callbackData = ctx.update.callback_query.data;

  if (callbackData.startsWith("stop-mesajdaki-")) {
    const user = callbackData.split("-")[2];
    exec(`ps aux | grep sshd`, (error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`);
        return;
      }

      const sessions = stdout.split("\n").filter(line => line.includes(user) && line.includes('@pts/'));
      if (sessions.length > 0) {
        const pid = sessions[0].trim().split(/\s+/)[1];
        exec(`kill -9 ${pid}`, (killError) => {
          if (killError) {
            console.error(`kill error: ${killError}`);
            return;
          }
          ctx.editMessageText(ctx.update.callback_query.message.text + "\n\nStatus: **deactive**", {parse_mode: 'Markdown'});


          ctx.answerCbQuery("Oturum sonlandırıldı.");
        });
      } else {
        ctx.answerCbQuery("Aktif oturum bulunamadı.");
        ctx.editMessageText(ctx.update.callback_query.message.text + "\n\nStatus: **deactive**", {parse_mode: 'Markdown'});


      }
    });
  }
});

bot.launch();

process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM'));

