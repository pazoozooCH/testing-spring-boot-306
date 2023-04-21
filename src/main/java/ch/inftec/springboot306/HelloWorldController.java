/*
 * Copyright 2023 by Swiss Post, Information Technology
 */

package ch.inftec.springboot306;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;

/**
 * @author martin.meyer@inftec.ch
 */
@RestController
@RequestMapping("/")
public class HelloWorldController {
  @GetMapping
  public String helloWorld() {
    return "Hello, it's " + new Date();
  }
}
