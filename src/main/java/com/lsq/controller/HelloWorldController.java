package com.lsq.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;


@Controller
@RequestMapping("/hello")
public class HelloWorldController {
	
	
   @RequestMapping("/helloWorld1")
    public ModelAndView helloWorld1(Model model) {
        String message = "Hello World1111, Spring 3.0!";
        System.out.println(message);
       return new ModelAndView("hello", "message", message);
    }
	   
	   
    @RequestMapping("/helloWorld")
    public ModelAndView helloWorld(Model model) {
        String message = "Hello World, Spring 3.0!";
        System.out.println(message);
       return new ModelAndView("hello", "message", message);
    }
    
}