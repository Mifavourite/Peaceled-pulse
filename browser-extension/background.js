// Background service worker for Recovery Journey extension

const pornKeywords = [
  'porn', 'xxx', 'sex', 'adult', 'nsfw', 'nude', 'naked',
  'hentai', 'erotic', 'explicit', 'mature', 'adult content',
  'pornhub', 'xvideos', 'redtube', 'youporn', 'xhamster',
  'onlyfans', 'chaturbate', 'cam4', 'livejasmin',
];

const warningVerses = [
  {
    reference: '1 Corinthians 6:18',
    text: 'Flee from sexual immorality. All other sins a person commits are outside the body, but whoever sins sexually, sins against their own body.'
  },
  {
    reference: 'Matthew 5:28',
    text: 'But I tell you that anyone who looks at a woman lustfully has already committed adultery with her in his heart.'
  },
  {
    reference: 'Job 31:1',
    text: 'I made a covenant with my eyes not to look lustfully at a young woman.'
  },
  {
    reference: 'Proverbs 6:25',
    text: 'Do not lust in your heart after her beauty or let her captivate you with her eyes.'
  },
  {
    reference: 'Ephesians 5:3',
    text: 'But among you there must not be even a hint of sexual immorality, or of any kind of impurity, or of greed, because these are improper for God\'s people.'
  }
];

function isPornRelated(url) {
  const lowerUrl = url.toLowerCase();
  return pornKeywords.some(keyword => lowerUrl.includes(keyword));
}

function getRandomVerse() {
  const random = Math.floor(Math.random() * warningVerses.length);
  return warningVerses[random];
}

// Listen for tab updates
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === 'loading' && tab.url) {
    if (isPornRelated(tab.url)) {
      // Log the attempt
      const date = new Date().toISOString().split('T')[0];
      chrome.storage.local.get([`attempts_${date}`], (result) => {
        const attempts = result[`attempts_${date}`] || [];
        attempts.push({
          url: tab.url,
          timestamp: Date.now(),
          time: new Date().toLocaleTimeString()
        });
        chrome.storage.local.set({ [`attempts_${date}`]: attempts });
      });

      // Redirect to warning page
      chrome.tabs.update(tabId, {
        url: chrome.runtime.getURL('warning.html') + '?url=' + encodeURIComponent(tab.url)
      });
    }
  }
});
