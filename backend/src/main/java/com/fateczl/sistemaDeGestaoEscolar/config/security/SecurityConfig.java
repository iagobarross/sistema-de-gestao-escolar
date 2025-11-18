package com.fateczl.sistemaDeGestaoEscolar.config.security;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. Adiciona a configuração de CORS que definimos abaixo
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))

                // 2. Desabilita o CSRF (você já tinha)
                .csrf(csrf -> csrf.disable())

                // 3. Define a sessão como stateless (você já tinha)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                .authorizeHttpRequests(authorize -> authorize
                        // 4. Permite tudo para /escola e /disciplina (para testes)
                        .requestMatchers(HttpMethod.OPTIONS,"/**").permitAll()
                        .requestMatchers("/api/v1/escola/**").permitAll()
                        .requestMatchers("/api/v1/disciplina/**").permitAll()
                        .requestMatchers("/api/v1/aluno/**").permitAll()
                        .requestMatchers("/api/v1/responsavel/**").permitAll()
                        .requestMatchers("/api/v1/turma/**").permitAll()
                        .anyRequest().authenticated())
                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable());

        return http.build();
    }

    // 5. BEAN DE CONFIGURAÇÃO DO CORS
    // Este método define as regras de permissão
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Permite requisições de qualquer origem (ex: FlutterFlow, ngrok, localhost)
        configuration.setAllowedOrigins(List.of("*"));

        // Permite os métodos HTTP que usaremos
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD"));

        // Permite todos os cabeçalhos
        configuration.setAllowedHeaders(List.of("*"));

       // configuration.setAllowCredentials(true);

       // configuration.setExposedHeaders(List.of("Authorization"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        // Aplica esta configuração a TODOS os caminhos da sua API
        source.registerCorsConfiguration("/**", configuration);

        return source;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        // BCrypt é o algoritmo de hashing mais recomendado
        return new BCryptPasswordEncoder();
    }
}