package com.fateczl.sistemaDeGestaoEscolar.auth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthenticationResponseDTO {
    private String accessToken;
    private String refreshToken;
}
