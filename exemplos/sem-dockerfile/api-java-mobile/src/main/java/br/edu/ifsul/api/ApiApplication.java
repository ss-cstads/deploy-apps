package br.edu.ifsul.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@SpringBootApplication
public class ApiApplication implements WebMvcConfigurer {

    public static void main(String[] args) {
        SpringApplication.run(ApiApplication.class, args);
    }

    // Apps nativos (Android/iOS) não precisam de CORS; apps híbridos e web
    // (Ionic, React Native Web, Flutter Web) precisam.
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE");
    }
}
