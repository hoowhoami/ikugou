package org.swordsmen.kugoumusic.core.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * @author JLT
 * Create by 2025/4/17
 */
@EnableConfigurationProperties(KugouProperties.class)
@Configuration
public class KugouConfig {

    @Bean
    public KugouTemplate kugouTemplate(KugouProperties kugouProperties) {
        return new KugouTemplate(kugouProperties);
    }

}
