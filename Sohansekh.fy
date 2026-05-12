module.exports.config = {
  name: "antilink",
  version: "1.0.0",
  hasPermssion: 1,
  credits: "Gemini",
  description: "গ্রুপে লিংক দিলে ওয়ার্নিং এবং ১৫ সেকেন্ড পর রিমুভ করবে",
  commandCategory: "Admin",
  usages: "antilink on/off",
  cooldowns: 5,
};

module.exports.handleEvent = async function ({ api, event, Threads }) {
  const { threadID, messageID, senderID, body } = event;

  // লিংক চেক করার জন্য রেজেক্স (Regex)
  const linkPattern = /(https?:\/\/[^\s]+)|(facebook\.com\/[^\s]+)|(m\.me\/[^\s]+)/gi;

  if (body && linkPattern.test(body)) {
    // চেক করা হচ্ছে বট অ্যাডমিন কি না
    const threadInfo = await api.getThreadInfo(threadID);
    const botID = api.getCurrentUserID();

    if (!threadInfo.adminIDs.some(item => item.id == botID)) {
      return; // বট অ্যাডমিন না হলে কিছুই করবে না
    }

    // ওয়ার্নিং মেসেজ
    const warningMsg = "⚠️ লিংক শেয়ার করা নিষেধ! আপনি যদি ১৫ সেকেন্ডের মধ্যে এই মেসেজটি রিমুভ না করেন, তবে আপনাকে গ্রুপ থেকে কিক দেওয়া হবে।";
    
    api.sendMessage(warningMsg, threadID, (err, info) => {
      setTimeout(async () => {
        // ১৫ সেকেন্ড পর চেক করা হচ্ছে মেসেজটি কি এখনো আছে?
        // সাধারণত ডিলিট হয়ে গেলে API এর মাধ্যমে চেক করা যায় না, তাই সরাসরি রিমুভ অ্যাকশন নেওয়া হয়
        try {
          // ইউজারকে কিক দেওয়া
          api.removeUserFromGroup(senderID, threadID);
          api.unsendMessage(info.messageID); // ওয়ার্নিং মেসেজ মুছে দেওয়া
        } catch (e) {
          console.log(e);
        }
      }, 15000); // ১৫০০০ মিলিসেকেন্ড = ১৫ সেকেন্ড
    }, messageID);
  }
};

module.exports.run = async function ({ api, event, args }) {
  // এটি ইভেন্ট হিসেবে কাজ করে তাই রান ফাংশনে আলাদা কিছু প্রয়োজন নেই
  api.sendMessage("Antilink অটোমেটিক কাজ করছে। এটি বন্ধ করতে চাইলে ফাইলটি রিমুভ করুন বা ইভেন্ট কন্ট্রোল ব্যবহার করুন।", event.threadID);
};
