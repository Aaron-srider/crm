package com.wc.web.listener;

import com.wc.settings.domain.DicValue;
import com.wc.settings.service.DicService;
import com.wc.settings.service.Impl.DicServiceImpl;
import com.wc.utils.ServiceFactory;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

public class ContextListener implements ServletContextListener {

    /**
     * 监听context对象的启动行为
     * @param sce - 从中可以取得监听的上下文对象
     */
    public void contextInitialized(ServletContextEvent sce) {

        System.out.println("开始读取数据字典");

        //获取上下文对象
        ServletContext application = sce.getServletContext();

        //从数据库中获取数据字典
        DicService dicService = (DicService) ServiceFactory.getService(new DicServiceImpl());

        //字典类型为key，字典值列表为值
        Map<String, List<DicValue>> dicMap = dicService.getAllDic();

        //将数据字典存入上下文对象中
        Set<String> dicTypes = dicMap.keySet();
        for (String dicType : dicTypes) {
            List<DicValue> dicValues = dicMap.get(dicType);
            application.setAttribute(dicType, dicValues);
        }

        //控制台打印所有数据字典的类型
        System.out.println("数据字典类型:");
        Enumeration<String> attributeNames = application.getAttributeNames();

        while(attributeNames.hasMoreElements()) {
            String nextElement = attributeNames.nextElement();
            if(!nextElement.contains(".")) {
                System.out.println(nextElement);
            }
        }

        System.out.println("数据字典读取完毕");


        System.out.println("解析Stage2Possibility.properties");
        ResourceBundle resourceBundle = ResourceBundle.getBundle("Stage2Possibility");

        Enumeration<String> keys = resourceBundle.getKeys();
        Map<String, String> possibilityMap = new HashMap<String, String>();

        while(keys.hasMoreElements()) {
            String key = keys.nextElement();
            String value = resourceBundle.getString(key);

            System.out.println(key + ":" + value);

            possibilityMap.put(key,value);
        }

        application.setAttribute("possibilityMap", possibilityMap);
        System.out.println("解析完毕");
    }
}
