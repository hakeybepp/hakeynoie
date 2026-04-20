import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from "react";

import type { UserOut } from "../api/auth";

interface AuthUser {
  id: string;
  is_admin: boolean;
}

interface AuthContextValue {
  user: AuthUser | null;
  ready: boolean;
  login: (token: string, user: UserOut) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue>({
  user: null,
  ready: false,
  login: () => {},
  logout: () => {},
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem("access_token");
    const stored = localStorage.getItem("auth_user");
    if (token && stored) {
      try {
        const parsed: UserOut = JSON.parse(stored);
        setUser({ id: parsed.id, is_admin: parsed.is_admin });
      } catch {
        localStorage.removeItem("access_token");
        localStorage.removeItem("auth_user");
      }
    }
    setReady(true);
  }, []);

  const login = useCallback((token: string, userData: UserOut) => {
    localStorage.setItem("access_token", token);
    localStorage.setItem("auth_user", JSON.stringify(userData));
    setUser({ id: userData.id, is_admin: userData.is_admin });
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem("access_token");
    localStorage.removeItem("auth_user");
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider value={{ user, ready, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
