package org.swordsmen.kugoumusic.core.entity;

import lombok.Data;

import java.io.Serializable;

/**
 * @author JLT
 * Create by 2025/4/16
 */
@Data
public class AbstractKugouRequest implements Serializable {

    private String dfid;
    private String mid;
    private String uuid;
    private String appid;
    private String clientver;
    private String clienttime;
    private String userid;
    private String token;
    private String key;
    private String signature;

}
