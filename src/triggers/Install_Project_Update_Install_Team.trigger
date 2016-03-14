trigger Install_Project_Update_Install_Team on Install_Project__c (after insert, after update, after delete) {
    Map<Id,String> teamTypes = new Map<Id,String>();
    
    Map<Id,Integer> projectsAhead = new Map<Id,Integer>();
    Map<Id,Integer> projectsBehind = new Map<Id,Integer>();
    Map<Id,Double> projectsDelta = new Map<Id,Double>();
    
    Date startQuarter;
    Date endQuarter;
    //current year and month
    Integer qYear = Date.today().year();
    Integer qMonth = Date.today().month();
    String qNumber;
    if(qMonth>=1&&qMonth<4){
        startQuarter = Date.newInstance(qYear,1,1);
        endQuarter = Date.newInstance(qYear,3,31);
        qNumber = 'Q1';
    } else if(qMonth>3&&qMonth<7){
        startQuarter = Date.newInstance(qYear,4,1);
        endQuarter = Date.newInstance(qYear,6,30);
        qNumber = 'Q2';
    } else if(qMonth>6&&qMonth<10){
        startQuarter = Date.newInstance(qYear,7,1);
        endQuarter = Date.newInstance(qYear,9,30);
        qNumber = 'Q3';
    } else if(qMonth>9&&qMonth<=12){
        startQuarter = Date.newInstance(qYear,10,1);
        endQuarter = Date.newInstance(qYear,12,31);
        qNumber = 'Q4';
    }
    
    List<Install_Project__c> instProjects = new List<Install_Project__c>([SELECT id, Electrician_Team__c, Electrician_Bonus_Hours_Used_vs_Budget__c, Installer_Team__c, Installer_Bonus_Hours_Used_vs_Budget__c FROM Install_Project__c WHERE Date_Completed2__c>=:startQuarter AND Date_Completed2__c<=:endQuarter]);

    for(Install_Project__c instProj : instProjects){
        //handle electrician teams
        if(instProj.Electrician_Team__c!=null&&instProj.Electrician_Bonus_Hours_Used_vs_Budget__c!=null){
            if(instProj.Electrician_Bonus_Hours_Used_vs_Budget__c>=0){
                if(projectsAhead.containsKey(instProj.Electrician_Team__c)){
                    projectsAhead.put(instProj.Electrician_Team__c,projectsAhead.get(instProj.Electrician_Team__c)+1);
                }else{
                    projectsAhead.put(instProj.Electrician_Team__c,1);
                }
            } else if (instProj.Electrician_Bonus_Hours_Used_vs_Budget__c<0){
                if(projectsBehind.containsKey(instProj.Electrician_Team__c)){
                    projectsBehind.put(instProj.Electrician_Team__c,projectsBehind.get(instProj.Electrician_Team__c)+1);
                }else{
                    projectsBehind.put(instProj.Electrician_Team__c,1);
                }
            }
            if(projectsDelta.containsKey(instProj.Electrician_Team__c)){
                projectsDelta.put(instProj.Electrician_Team__c,projectsDelta.get(instProj.Electrician_Team__c)+instProj.Electrician_Bonus_Hours_Used_vs_Budget__c);
            } else {
                projectsDelta.put(instProj.Electrician_Team__c,instProj.Electrician_Bonus_Hours_Used_vs_Budget__c);
            }
        }
        //handle installer teams
        if(instProj.Installer_Team__c!=null&&instProj.Installer_Bonus_Hours_Used_vs_Budget__c !=null){
            if(instProj.Installer_Bonus_Hours_Used_vs_Budget__c >=0){
                if(projectsAhead.containsKey(instProj.Installer_Team__c)){
                    projectsAhead.put(instProj.Installer_Team__c,projectsAhead.get(instProj.Installer_Team__c)+1);
                }else{
                    projectsAhead.put(instProj.Installer_Team__c,1);
                }
            } else if (instProj.Installer_Bonus_Hours_Used_vs_Budget__c <0){
                if(projectsBehind.containsKey(instProj.Installer_Team__c)){
                    projectsBehind.put(instProj.Installer_Team__c,projectsBehind.get(instProj.Installer_Team__c)+1);
                }else{
                    projectsBehind.put(instProj.Installer_Team__c,1);
                }
            }
            if(projectsDelta.containsKey(instProj.Installer_Team__c)){
                projectsDelta.put(instProj.Installer_Team__c,projectsDelta.get(instProj.Installer_Team__c)+instProj.Installer_Bonus_Hours_Used_vs_Budget__c );
            } else {
                projectsDelta.put(instProj.Installer_Team__c,instProj.Installer_Bonus_Hours_Used_vs_Budget__c );
            }
        }
    }
    List<Install_Team__c> instTeams = new List<Install_Team__c>([SELECT id, Team_Type__c FROM Install_Team__c]);
    List<Install_Team__c> updateTeams = new List<Install_Team__c>();
    List<Quarterly_Bonus__c> qBonuses = new List<Quarterly_Bonus__c>([SELECT id, Install_Team__c, Number_of_Projects_Behind_Budget__c, Number_Of_Projects_Ahead_of_Budget__c, Total_Number_of_Hours_Ahead_Behind__c FROM Quarterly_Bonus__c WHERE Year__c=:qYear AND Quarter__c=:qNumber]);
    List<Quarterly_Bonus__c> updateBonuses = new List<Quarterly_Bonus__c>();
    Map<Id,Quarterly_Bonus__c> bonusTeams = new Map<Id,Quarterly_Bonus__c>();
    for(Quarterly_Bonus__c qb: qBonuses){
        bonusTeams.put(qb.Install_Team__c,qb);
    }
    
    for (Install_Team__c instTeam : instTeams){
        Install_Team__c itm = instTeam;
        Quarterly_Bonus__c qb;
        if(bonusTeams.containsKey(instTeam.id)){
            qb = bonusTeams.get(instTeam.id);
        } else {
            qb = new Quarterly_Bonus__c();
            qb.Year__c=qYear;
            qb.Quarter__c=qNumber;
            qb.Install_Team__c=instTeam.id;
        }
        if(projectsAhead.containsKey(instTeam.id)){
            itm.Number_Of_Projects_Ahead_of_Budget__c = qb.Number_Of_Projects_Ahead_of_Budget__c = projectsAhead.get(instTeam.id);
        }
        if(projectsBehind.containsKey(instTeam.id)){
            itm.Number_of_Projects_Behind_Budget__c = qb.Number_of_Projects_Behind_Budget__c = projectsBehind.get(instTeam.id);
        }
        if(projectsDelta.containsKey(instTeam.id)){
            itm.Total_Number_of_Hours_Ahead_Behind__c = qb.Total_Number_of_Hours_Ahead_Behind__c = projectsDelta.get(instTeam.id);
        }
        updateTeams.add(itm);
        updateBonuses.add(qb);
    }
    
    update updateTeams;
    upsert updateBonuses;
    
    
}