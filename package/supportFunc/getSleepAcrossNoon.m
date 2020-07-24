function n = getSleepAcrossNoon(ACT, startDate, endDate)

events = selectEventsUsingTime(ACT.analysis.events, startDate, endDate, ...
        'Label', 'sleepWindow', ...
        'Type', ACT.analysis.settings.sleepWindowType);
    
n = sum(mod(events.onset,1) < 0.5 & mod(events.onset,1)+events.duration > 0.5);