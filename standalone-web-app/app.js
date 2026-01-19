// App State
let currentUser = null;
let streak = 0;
let victories = [];
let checkins = [];
let values = [];
let selectedMood = null;
let selectedTriggers = [];

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadData();
    setupEventListeners();
    showDailyQuote();
    
    // Check if user is logged in
    const savedUser = localStorage.getItem('currentUser');
    if (savedUser) {
        currentUser = savedUser;
        showApp();
    }
});

// Event Listeners
function setupEventListeners() {
    // Login/Register
    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    document.getElementById('registerForm').addEventListener('submit', handleRegister);
    document.getElementById('showRegister').addEventListener('click', () => {
        document.getElementById('loginForm').style.display = 'none';
        document.getElementById('registerForm').style.display = 'block';
    });
    document.getElementById('showLogin').addEventListener('click', () => {
        document.getElementById('registerForm').style.display = 'none';
        document.getElementById('loginForm').style.display = 'block';
    });
    
    // Navigation
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const screen = e.currentTarget.dataset.screen;
            showScreen(screen);
        });
    });
    
    // Logout
    document.getElementById('logoutBtn')?.addEventListener('click', handleLogout);
}

// Authentication
function handleLogin(e) {
    e.preventDefault();
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    const users = JSON.parse(localStorage.getItem('users') || '[]');
    const user = users.find(u => u.username === username && u.password === password);
    
    if (user) {
        currentUser = username;
        localStorage.setItem('currentUser', username);
        loadUserData();
        showApp();
    } else {
        alert('Invalid username or password');
    }
}

function handleRegister(e) {
    e.preventDefault();
    const username = document.getElementById('regUsername').value;
    const password = document.getElementById('regPassword').value;
    const confirm = document.getElementById('regPasswordConfirm').value;
    
    if (password !== confirm) {
        alert('Passwords do not match');
        return;
    }
    
    const users = JSON.parse(localStorage.getItem('users') || '[]');
    if (users.find(u => u.username === username)) {
        alert('Username already exists');
        return;
    }
    
    users.push({ username, password });
    localStorage.setItem('users', JSON.stringify(users));
    
    currentUser = username;
    localStorage.setItem('currentUser', username);
    initializeUserData();
    showApp();
}

function handleLogout() {
    currentUser = null;
    localStorage.removeItem('currentUser');
    document.getElementById('loginScreen').classList.add('active');
    document.getElementById('appScreen').classList.remove('active');
}

function showApp() {
    document.getElementById('loginScreen').classList.remove('active');
    document.getElementById('appScreen').classList.add('active');
    updateDashboard();
}

// Screen Navigation
function showScreen(screenName) {
    // Hide all content screens
    document.querySelectorAll('.content-screen').forEach(screen => {
        screen.classList.remove('active');
    });
    
    // Show selected screen
    document.getElementById(screenName).classList.add('active');
    
    // Update nav buttons
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.screen === screenName) {
            btn.classList.add('active');
        }
    });
    
    // Load screen-specific data
    if (screenName === 'victory') {
        displayVictories();
        updateChart();
    } else if (screenName === 'checkin') {
        displayCheckinHistory();
    } else if (screenName === 'values') {
        displayValues();
    }
}

// Dashboard
function updateDashboard() {
    loadUserData();
    calculateStreak();
    document.getElementById('streakCount').textContent = streak;
    document.getElementById('totalVictories').textContent = victories.length;
    
    // Calculate week victories
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    const weekVictories = victories.filter(v => new Date(v.date) >= weekAgo).length;
    document.getElementById('weekVictories').textContent = weekVictories;
    
    // Update milestone badge
    let badge = '🌱';
    if (streak >= 365) badge = '💎';
    else if (streak >= 90) badge = '🏅';
    else if (streak >= 30) badge = '⭐';
    else if (streak >= 7) badge = '🌟';
    document.getElementById('milestoneBadge').textContent = badge;
}

function calculateStreak() {
    if (victories.length === 0) {
        streak = 0;
        return;
    }
    
    // Sort victories by date
    const sorted = [...victories].sort((a, b) => new Date(b.date) - new Date(a.date));
    
    streak = 0;
    let expectedDate = new Date();
    expectedDate.setHours(0, 0, 0, 0);
    
    for (let victory of sorted) {
        const victoryDate = new Date(victory.date);
        victoryDate.setHours(0, 0, 0, 0);
        
        const diffDays = Math.floor((expectedDate - victoryDate) / (1000 * 60 * 60 * 24));
        
        if (diffDays === 0) {
            streak++;
            expectedDate.setDate(expectedDate.getDate() - 1);
        } else if (diffDays === 1 && streak === 0) {
            streak++;
            expectedDate.setDate(expectedDate.getDate() - 1);
        } else {
            break;
        }
    }
}

function showDailyQuote() {
    const quotes = [
        "Recovery is not a race. It's a journey taken one day at a time.",
        "Every day is a new beginning. Take a deep breath and start again.",
        "You are stronger than you know. You've made it this far.",
        "Progress, not perfection. Every step forward counts.",
        "You deserve happiness and peace. Keep going.",
        "Healing takes time, but every day you're getting stronger.",
        "Your past doesn't define you. Today is a fresh start.",
        "You are not alone in this journey. Support is always available.",
        "Small steps lead to big changes. Be patient with yourself.",
        "You are capable of more than you can imagine."
    ];
    
    const randomQuote = quotes[Math.floor(Math.random() * quotes.length)];
    document.getElementById('dailyQuote').textContent = `"${randomQuote}"`;
}

// Victory Log
function logVictory() {
    const notes = document.getElementById('victoryNotes').value.trim();
    if (!notes) {
        alert('Please enter a note about your victory');
        return;
    }
    
    const victory = {
        id: Date.now(),
        date: new Date().toISOString(),
        notes: notes
    };
    
    victories.push(victory);
    saveUserData();
    document.getElementById('victoryNotes').value = '';
    displayVictories();
    updateChart();
    updateDashboard();
    
    alert('Victory logged! 🎉');
}

function displayVictories() {
    const container = document.getElementById('victoryList');
    
    if (victories.length === 0) {
        container.innerHTML = '<p class="empty-state">No victories logged yet. Log your first victory above!</p>';
        return;
    }
    
    const sorted = [...victories].sort((a, b) => new Date(b.date) - new Date(a.date));
    
    container.innerHTML = sorted.map(victory => {
        const date = new Date(victory.date);
        const dateStr = date.toLocaleDateString('en-US', { 
            month: 'short', 
            day: 'numeric', 
            year: 'numeric' 
        });
        
        return `
            <div class="victory-item">
                <div>
                    <div style="font-weight: 500; margin-bottom: 5px;">${victory.notes}</div>
                    <div class="victory-date">${dateStr}</div>
                </div>
                <span style="font-size: 24px;">🎉</span>
            </div>
        `;
    }).join('');
}

function updateChart() {
    const container = document.getElementById('chartContainer');
    const last30Days = [];
    
    for (let i = 29; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        date.setHours(0, 0, 0, 0);
        
        const victoriesCount = victories.filter(v => {
            const vDate = new Date(v.date);
            vDate.setHours(0, 0, 0, 0);
            return vDate.getTime() === date.getTime();
        }).length;
        
        last30Days.push({
            date: date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
            count: victoriesCount
        });
    }
    
    const maxCount = Math.max(...last30Days.map(d => d.count), 1);
    
    container.innerHTML = last30Days.map(day => {
        const height = (day.count / maxCount) * 100;
        return `
            <div style="display: flex; flex-direction: column; align-items: center; gap: 5px;">
                <div class="chart-bar" style="height: ${height}%;"></div>
                <small style="font-size: 10px; color: #666;">${day.date.split(' ')[1]}</small>
            </div>
        `;
    }).join('');
}

// Check-In
function selectMood(mood) {
    selectedMood = mood;
    document.querySelectorAll('.mood-btn').forEach(btn => {
        btn.classList.remove('selected');
    });
    document.querySelector(`[data-mood="${mood}"]`).classList.add('selected');
}

function toggleTrigger(trigger) {
    const index = selectedTriggers.indexOf(trigger);
    const btn = event.target;
    
    if (index > -1) {
        selectedTriggers.splice(index, 1);
        btn.classList.remove('selected');
    } else {
        selectedTriggers.push(trigger);
        btn.classList.add('selected');
    }
}

function submitCheckin() {
    if (!selectedMood) {
        alert('Please select how you are feeling');
        return;
    }
    
    const checkin = {
        id: Date.now(),
        date: new Date().toISOString(),
        mood: selectedMood,
        triggers: [...selectedTriggers],
        notes: document.getElementById('checkinNotes').value.trim()
    };
    
    checkins.push(checkin);
    saveUserData();
    
    // Reset form
    selectedMood = null;
    selectedTriggers = [];
    document.getElementById('checkinNotes').value = '';
    document.querySelectorAll('.mood-btn').forEach(btn => btn.classList.remove('selected'));
    document.querySelectorAll('.tag-btn').forEach(btn => btn.classList.remove('selected'));
    
    displayCheckinHistory();
    alert('Check-in saved! 📝');
}

function displayCheckinHistory() {
    const container = document.getElementById('checkinHistory');
    
    if (checkins.length === 0) {
        container.innerHTML = '<p class="empty-state">No check-ins yet. Complete your first check-in above!</p>';
        return;
    }
    
    const sorted = [...checkins].sort((a, b) => new Date(b.date) - new Date(a.date));
    const recent = sorted.slice(0, 5);
    
    const moodEmojis = {
        'great': '😊',
        'good': '🙂',
        'okay': '😐',
        'difficult': '😔',
        'very-difficult': '😢'
    };
    
    container.innerHTML = recent.map(checkin => {
        const date = new Date(checkin.date);
        const dateStr = date.toLocaleDateString('en-US', { 
            month: 'short', 
            day: 'numeric', 
            year: 'numeric',
            hour: 'numeric',
            minute: '2-digit'
        });
        
        return `
            <div class="checkin-item">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
                    <span style="font-size: 24px;">${moodEmojis[checkin.mood]}</span>
                    <span class="victory-date">${dateStr}</span>
                </div>
                ${checkin.triggers.length > 0 ? `<div style="margin: 5px 0;"><small>Triggers: ${checkin.triggers.join(', ')}</small></div>` : ''}
                ${checkin.notes ? `<div style="color: #666; margin-top: 5px;">${checkin.notes}</div>` : ''}
            </div>
        `;
    }).join('');
}

// Values
function saveValues() {
    values = [];
    for (let i = 1; i <= 5; i++) {
        const value = document.getElementById(`value${i}`).value.trim();
        if (value) {
            values.push(value);
        }
    }
    
    saveUserData();
    displayValues();
    alert('Values saved! ❤️');
}

function displayValues() {
    const container = document.getElementById('valuesDisplay');
    
    if (values.length === 0) {
        container.innerHTML = '<p class="empty-state">Add your core values above</p>';
        return;
    }
    
    container.innerHTML = values.map(value => `
        <div class="value-item">
            <strong>❤️ ${value}</strong>
        </div>
    `).join('');
    
    // Populate form
    values.forEach((value, index) => {
        document.getElementById(`value${index + 1}`).value = value;
    });
}

// Breathing Exercise
let breathingInterval = null;
let breathingPhase = 'in';

function startBreathing() {
    document.getElementById('breathingExercise').style.display = 'flex';
    const circle = document.getElementById('breathingCircle');
    const text = document.getElementById('breathingText');
    
    breathingPhase = 'in';
    circle.classList.add('breathe-in');
    text.textContent = 'Breathe In';
    
    breathingInterval = setInterval(() => {
        if (breathingPhase === 'in') {
            breathingPhase = 'hold';
            circle.classList.remove('breathe-in');
            circle.classList.add('breathe-hold');
            text.textContent = 'Hold';
        } else if (breathingPhase === 'hold') {
            breathingPhase = 'out';
            circle.classList.remove('breathe-hold');
            circle.classList.add('breathe-out');
            text.textContent = 'Breathe Out';
        } else {
            breathingPhase = 'in';
            circle.classList.remove('breathe-out');
            circle.classList.add('breathe-in');
            text.textContent = 'Breathe In';
        }
    }, 4000);
}

function stopBreathing() {
    if (breathingInterval) {
        clearInterval(breathingInterval);
        breathingInterval = null;
    }
    document.getElementById('breathingExercise').style.display = 'none';
    document.getElementById('breathingCircle').className = 'breathing-circle';
}

// Data Management
function initializeUserData() {
    victories = [];
    checkins = [];
    values = [];
    saveUserData();
}

function loadUserData() {
    const userData = JSON.parse(localStorage.getItem(`userData_${currentUser}`) || '{}');
    victories = userData.victories || [];
    checkins = userData.checkins || [];
    values = userData.values || [];
}

function saveUserData() {
    const userData = {
        victories,
        checkins,
        values
    };
    localStorage.setItem(`userData_${currentUser}`, JSON.stringify(userData));
}

function loadData() {
    // Load any global data if needed
}
