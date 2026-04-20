export class ApiError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

async function apiClient<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const token = localStorage.getItem("access_token");
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };
  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const response = await fetch(`/api${path}`, { ...options, headers });

  if (response.status === 401) {
    localStorage.removeItem("access_token");
    localStorage.removeItem("auth_user");
    window.location.href = "/login";
    return undefined as T;
  }

  if (response.status === 204) {
    return undefined as T;
  }

  const data = await response.json();

  if (!response.ok) {
    throw new ApiError(response.status, data?.detail ?? response.statusText);
  }

  return data as T;
}

export default apiClient;
