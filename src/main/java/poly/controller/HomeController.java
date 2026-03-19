package poly.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {

    @RequestMapping("/pgv/home.htm")
    public String pgvHome() {
        return "pgv/home";
    }

    @RequestMapping("/gv/home.htm")
    public String gvHome() {
        return "gv/home";
    }

    @RequestMapping("/sv/home.htm")
    public String svHome() {
        return "sv/home";
    }
}