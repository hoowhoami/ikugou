package org.swordsmen.kugoumusic.core;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.annotation.ComponentScan;
import org.swordsmen.kugoumusic.core.util.ApplicationContextUtils;

/**
 * @author JLT
 * Create by 2024/9/3
 */
@ComponentScan("org.swordsmen.spark")
public abstract class AbstractApplication implements ApplicationContextAware {

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        ApplicationContextUtils.setApplicationContext(applicationContext);
    }

}
