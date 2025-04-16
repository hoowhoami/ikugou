package org.swordsmen.kugoumusic.api.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author JLT
 * Create by 2024/9/3
 */
@RestController
public class IndexController {

    @RequestMapping(value = {"", "/"})
    public String index() {
        return """
                {"status": 200, "msg": "Welcome to access kugou music api..."}
                """;
    }

}
