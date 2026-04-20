import apiClient from "./client";

export interface UserOut {
  id: string;
  email: string;
  full_name: string;
  is_admin: boolean;
}

export interface AuthResponse {
  access_token: string;
  token_type: string;
  user: UserOut;
}

export async function register(
  email: string,
  password: string,
  full_name: string,
  invite_code: string,
): Promise<AuthResponse> {
  return apiClient<AuthResponse>(
    "/auth/user/password/register",
    {
      method: "POST",
      body: JSON.stringify({ user: { email, password, full_name, invite_code } }),
    },
  );
}

export async function login(
  email: string,
  password: string,
): Promise<AuthResponse> {
  return apiClient<AuthResponse>("/auth/user/password/sign_in", {
    method: "POST",
    body: JSON.stringify({ user: { email, password } }),
  });
}
