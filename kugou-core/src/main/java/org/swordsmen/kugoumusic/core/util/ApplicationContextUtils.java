package org.swordsmen.kugoumusic.core.util;

import com.axin.tool.core.util.AxinStringUtils;
import lombok.Getter;
import org.springframework.context.ApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.core.env.EnvironmentCapable;
import org.swordsmen.kugoumusic.core.constant.ApplicationConstants;

import java.util.Arrays;
import java.util.Optional;

/**
 * @author JLT
 * Create by 2024/9/3
 */
public final class ApplicationContextUtils {

    private ApplicationContextUtils() {

    }

    @Getter
    private static ApplicationContext applicationContext;

    public static void setApplicationContext(ApplicationContext applicationContext) {
        ApplicationContextUtils.applicationContext = applicationContext;
    }

    public static boolean isProd() {
        return Optional.ofNullable(applicationContext)
                .map(EnvironmentCapable::getEnvironment)
                .map(Environment::getActiveProfiles)
                .map(a -> Arrays.stream(a).anyMatch(item -> AxinStringUtils.equalsIgnoreCase(item, ApplicationConstants.ACTIVE_PROFILES_PROD)))
                .orElse(false);
    }

}
