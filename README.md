![Example](https://graph.org/file/56cfa1f212133a5f651e2.jpg)

# SSH Notifier 

## What you need to do to make it work.
```
sudo touch /path/notifier.sh
sudo chmod +x /path/notifier.sh
sudo editor /path/notifier.sh
```
- Copy/Edit and paste code.
```
#!/usr/bin/env bash
TELEGRAM_TOKEN="token"
CHAT_ID="id"

TARGET_EMOJI=$'\U1F3AF'
IP_EMOJI=$'\U1F4EE'
USER_EMOJI=$'\U1F464'

if [ ${PAM_TYPE} = "open_session" ]; then
  MESSAGE=$(printf "**${TARGET_EMOJI} New Login detected!**\n\n${IP_EMOJI} **IP:** %s\n${USER_EMOJI} **User:** %s\n⌨ **Login Type:** %s" "$PAM_RHOST" "$PAM_USER" "$PAM_SERVICE")

  CALLBACK_DATA="stop-$PAM_USER"
  KEYBOARD="{\"inline_keyboard\":[[{\"text\":\"Stop Session\",\"callback_data\":\"$CALLBACK_DATA\"}]]}"

  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=$MESSAGE&parse_mode=Markdown&reply_markup=$KEYBOARD"
fi
```
- Part required for triggering;
```
sudo editor /etc/pam.d/sshd
```
- Add this to the end of the file:
```
session optional pam_exec.so path/notifier.sh
```

## FOR STOP SESSION BUTTON
- Download node & npm.
- Download telegraf.js library. 
```
npm install telegraf
```
- Create JavaScript file and copy/edit paste code.
```JavaScript
// notifier.js 
const { Telegraf } = require('telegraf');
const exec = require('child_process').exec;

const bot = new Telegraf('token');

bot.on('callback_query', (ctx) => {
  const callbackData = ctx.update.callback_query.data;

  if (callbackData.startsWith("stop-")) {
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


          ctx.answerCbQuery("Session Stopped.");
        });
      } else {
        ctx.answerCbQuery("User not active.");
        ctx.editMessageText(ctx.update.callback_query.message.text + "\n\nStatus: **deactive**", {parse_mode: 'Markdown'});


      }
    });
  }
});

bot.launch();

process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM'));
```

- Use linux screen or pm2 & run code.
  - Linux Screen
    ```
    screen -S notifierSession
    sudo node notifier.sh
    ```
  - Pm2
    ```
    sudo pm2 start notifier.js
    ```

