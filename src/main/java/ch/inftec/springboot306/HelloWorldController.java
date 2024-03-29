/*
 * Copyright 2023 by Swiss Post, Information Technology
 */

package ch.inftec.springboot306;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
  private Logger logger = LoggerFactory.getLogger(HelloWorldController.class);

  @GetMapping
  public String helloWorld() {
    var greeting = "Hello, it's " + new Date();
    logger.info("Greeting: {}", greeting);
    return greeting;
  }
}
