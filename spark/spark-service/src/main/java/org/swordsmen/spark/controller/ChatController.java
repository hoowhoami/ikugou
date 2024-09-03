package org.swordsmen.spark.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

/**
 * @author JLT
 * Create by 2024/9/3
 */
@RequestMapping("/chat")
@RestController
public class ChatController {

    @RequestMapping
    public Flux<String> index() {
        return Flux.just("Hello", "World");
    }

}
