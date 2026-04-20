package poly.filter;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.*;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);

        String uri = request.getRequestURI();

		// Bỏ qua trang login và logout
        if (uri.contains("/login.htm") || uri.contains("/logout.htm") 
                || uri.contains("/dangky.htm")) {
            chain.doFilter(req, res);
            return;
        }

        // Chưa đăng nhập → về login
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login.htm");
            return;
        }

        String role = (String) session.getAttribute("role");

        // Kiểm tra quyền theo URL
        if (uri.contains("/gv/") && !role.equals("GIAOVIEN") && !role.equals("PGV")) {
            response.sendRedirect(request.getContextPath() + "/login.htm");
            return;
        }	

        if (uri.contains("/sv/") && !role.equals("SINHVIEN")) {
            response.sendRedirect(request.getContextPath() + "/login.htm");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override public void init(FilterConfig config) {}
    @Override public void destroy() {}
}