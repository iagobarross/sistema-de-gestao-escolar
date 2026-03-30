package com.fateczl.sistemaDeGestaoEscolar.config.security;

import java.util.List;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final AuthenticationProvider authenticationProvider;

    @Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .cors(cors -> cors.configurationSource(corsConfigurationSource()))
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests(auth -> auth
            // Público
            .requestMatchers("/api/v1/auth/**").permitAll()
            .requestMatchers("/h2-console/**").permitAll()
            .requestMatchers("/ws-chat/**").permitAll()
            .requestMatchers("/v3/api-docs/**", "/swagger-ui/**").permitAll()

            // Somente Admin da Prefeitura
            .requestMatchers(HttpMethod.POST, "/api/v1/escola/com-diretor").hasRole("ADMIN")
            .requestMatchers(HttpMethod.DELETE, "/api/v1/escola/**").hasRole("ADMIN")
            .requestMatchers("/api/v1/funcionario/**").hasAnyRole("ADMIN", "DIRETOR")

            // Admin + Diretor podem criar/editar recursos da escola
            .requestMatchers(HttpMethod.POST, "/api/v1/escola").hasRole("ADMIN")
            .requestMatchers(HttpMethod.PUT, "/api/v1/escola/**").hasRole("ADMIN")
            .requestMatchers(HttpMethod.POST, "/api/v1/turma").hasAnyRole("ADMIN","DIRETOR","SECRETARIA")
            .requestMatchers(HttpMethod.PUT, "/api/v1/turma/**").hasAnyRole("ADMIN","DIRETOR","SECRETARIA")
            .requestMatchers(HttpMethod.DELETE, "/api/v1/turma/**").hasAnyRole("ADMIN","DIRETOR")

            // Alunos — SECRETARIA gerencia, demais leem
            .requestMatchers(HttpMethod.POST, "/api/v1/aluno").hasAnyRole("ADMIN","SECRETARIA")
            .requestMatchers(HttpMethod.PUT, "/api/v1/aluno/**").hasAnyRole("ADMIN","SECRETARIA")
            .requestMatchers(HttpMethod.DELETE, "/api/v1/aluno/**").hasAnyRole("ADMIN","SECRETARIA")

            // Disciplinas — somente Admin gerencia
            .requestMatchers(HttpMethod.POST, "/api/v1/disciplina").hasRole("ADMIN")
            .requestMatchers(HttpMethod.PUT, "/api/v1/disciplina/**").hasRole("ADMIN")
            .requestMatchers(HttpMethod.DELETE, "/api/v1/disciplina/**").hasRole("ADMIN")

            // Tudo autenticado pode fazer GET
            .anyRequest().authenticated()
        )
        .sessionManagement(session -> session
            .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .authenticationProvider(authenticationProvider)
        .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

    http.headers(h -> h.frameOptions(f -> f.disable()));
    return http.build();
}

    // 5. BEAN DE CONFIGURAÇÃO DO CORS
    // Este método define as regras de permissão
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        //substiuida temp. para teste web Socket
        // configuration.setAllowedOrigins(List.of("*"));
        configuration.setAllowedOriginPatterns(List.of("*"));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}