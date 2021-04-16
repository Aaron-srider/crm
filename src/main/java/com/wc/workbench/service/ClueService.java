package com.wc.workbench.service;

import com.wc.workbench.domain.Activity;
import com.wc.workbench.domain.Clue;
import com.wc.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface ClueService {

    boolean saveClue(Clue clue);

    List<Clue> showClueList(Clue clue);

    Clue getClueById(String id);

    List<Activity> getRelatedActivityByClueId(String id);

    boolean delRelationByClueIdAndActivityId(Map<String, String> map);

    List<Activity> getAllActivities();


    List<Activity> getAllActivitiesByNameAndNotRelatedWithClue(Map<String, String> map);

    boolean relateClueAndActivities(String clueId, String[] actIds);

    List<Activity> searchActivityByName(String aname);

    boolean convert(String clueId, Tran transaction, String createBy);

}
