const scoreboard = document.getElementById('scoreboard');
const playerList = document.getElementById('player-list');
const jobCounts = document.getElementById('job-counts');
const playerCount = document.getElementById('player-count');
const maxPlayers = document.getElementById('max-players');
const serverName = document.getElementById('server-name');

window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === 'open') {
        scoreboard.classList.add('visible');
        serverName.textContent = data.serverName || 'SERVER NAME';
        maxPlayers.textContent = data.maxPlayers || '64';
        
        if (!data.showJobs) {
            jobCounts.style.display = 'none';
        } else {
            jobCounts.style.display = 'flex';
        }
    } else if (data.action === 'close') {
        scoreboard.classList.remove('visible');
    } else if (data.action === 'updateData') {
        updateScoreboard(data.players, data.jobs);
    }
});

function updateScoreboard(players, jobs) {
    // Update player count
    playerCount.textContent = players.length;
    
    // Update job counts
    jobCounts.innerHTML = '';
    jobs.forEach(job => {
        const jobItem = document.createElement('div');
        jobItem.className = 'job-item';
        jobItem.innerHTML = `
            <div class="job-icon">${job.icon}</div>
            <div class="job-label">${job.label}</div>
            <div class="job-count">${job.count}</div>
        `;
        jobCounts.appendChild(jobItem);
    });
    
    // Update player list
    playerList.innerHTML = '';
    players.forEach(player => {
        const playerItem = document.createElement('div');
        playerItem.className = 'player-item';
        if (player.onDuty === false) {
            playerItem.classList.add('off-duty');
        }
        
        playerItem.innerHTML = `
            <div class="player-name">${player.name}</div>
            <div class="player-job">${player.job}</div>
            <div class="player-id">#${player.id}</div>
        `;
        playerList.appendChild(playerItem);
    });
}

// Close on ESC
document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape' || event.key === 'Home') {
        closeScoreboard();
    }
});

function closeScoreboard() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(error => console.error('Error closing scoreboard:', error));
}
