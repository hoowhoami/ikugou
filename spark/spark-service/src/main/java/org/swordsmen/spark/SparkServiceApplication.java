package org.swordsmen.spark;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.swordsmen.spark.core.AbstractApplication;

/**
 * @author JLT
 * Create by 2024/9/3
 */
@SpringBootApplication
public class SparkServiceApplication extends AbstractApplication {

    public static void main(String[] args) {
        SpringApplication.run(SparkServiceApplication.class, args);
    }

}
