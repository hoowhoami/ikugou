package org.swordsmen.kugoumusic.core.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;

/**
 * @author JLT
 * Create by 2025/4/16
 */
@Data
public class AbstractKugouResponse implements Serializable {

    private Integer status;

    @JsonProperty("error_code")
    private Integer errorCode;

    private String msg;

}
