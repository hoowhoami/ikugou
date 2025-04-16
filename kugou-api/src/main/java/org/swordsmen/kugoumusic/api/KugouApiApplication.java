package org.swordsmen.kugoumusic.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.swordsmen.kugoumusic.core.AbstractApplication;

/**
 * @author JLT
 * Create by 2024/9/3
 */
@SpringBootApplication
public class KugouApiApplication extends AbstractApplication {

    public static void main(String[] args) {
        SpringApplication.run(KugouApiApplication.class, args);
    }

}
