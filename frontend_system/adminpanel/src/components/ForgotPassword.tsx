import React, { useState } from "react";
import { Link } from "react-router-dom";
import API from "../api";
import toast from "react-hot-toast";
import { FiMail, FiArrowLeft, FiSend } from "react-icons/fi";

const ForgotPassword: React.FC = () => {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!email) {
      toast.error("Please enter your email");
      return;
    }

    setLoading(true);
    try {
      await API.post("/auth/forgot-password", { email });
      setSent(true);
      toast.success("Reset link sent to your email!");
    } catch (err: unknown) {
      const error = err as { response?: { data?: { message?: string } } };
      toast.error(error.response?.data?.message || "Request failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "var(--gradient-bg)",
        position: "relative",
        overflow: "hidden",
      }}
    >
      {/* Background decoration */}
      <div
        style={{
          position: "absolute",
          top: "-20%",
          left: "50%",
          transform: "translateX(-50%)",
          width: "600px",
          height: "600px",
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(16, 185, 129, 0.07) 0%, transparent 70%)",
          pointerEvents: "none",
        }}
      />

      <div
        className="glass-card animate-fade-in-up"
        style={{
          width: "100%",
          maxWidth: "440px",
          padding: "48px 40px",
          position: "relative",
          zIndex: 1,
        }}
      >
        {/* Back link */}
        <Link
          to="/"
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: "6px",
            fontSize: "13px",
            color: "var(--color-text-muted)",
            marginBottom: "28px",
            fontWeight: 500,
          }}
        >
          <FiArrowLeft size={16} /> Back to login
        </Link>

        {!sent ? (
          <>
            {/* Header */}
            <div style={{ marginBottom: "32px" }}>
              <div
                style={{
                  width: "56px",
                  height: "56px",
                  borderRadius: "var(--radius-md)",
                  background: "var(--gradient-primary)",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  marginBottom: "20px",
                  boxShadow: "0 8px 32px rgba(16, 185, 129, 0.3)",
                }}
              >
                <FiMail size={26} color="#fff" />
              </div>
              <h1 style={{ fontSize: "26px", fontWeight: 700, marginBottom: "8px" }}>
                Forgot Password?
              </h1>
              <p style={{ color: "var(--color-text-muted)", fontSize: "14px", lineHeight: 1.6 }}>
                No worries! Enter your email address and we'll send you a reset link.
              </p>
            </div>

            {/* Form */}
            <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
              <div>
                <label
                  style={{
                    display: "block",
                    fontSize: "13px",
                    fontWeight: 500,
                    color: "var(--color-text-secondary)",
                    marginBottom: "8px",
                  }}
                >
                  Email Address
                </label>
                <div style={{ position: "relative" }}>
                  <FiMail
                    size={18}
                    style={{
                      position: "absolute",
                      left: "14px",
                      top: "50%",
                      transform: "translateY(-50%)",
                      color: "var(--color-text-muted)",
                    }}
                  />
                  <input
                    id="forgot-email"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="you@example.com"
                    style={{
                      width: "100%",
                      padding: "12px 14px 12px 44px",
                      background: "var(--color-bg-input)",
                      border: "1px solid var(--color-border)",
                      borderRadius: "var(--radius-sm)",
                      color: "var(--color-text-primary)",
                      fontSize: "14px",
                      outline: "none",
                      transition: "border-color var(--transition-fast)",
                    }}
                    onFocus={(e) => (e.target.style.borderColor = "var(--color-primary)")}
                    onBlur={(e) => (e.target.style.borderColor = "var(--color-border)")}
                  />
                </div>
              </div>

              <button
                id="forgot-submit"
                type="submit"
                disabled={loading}
                style={{
                  width: "100%",
                  padding: "14px",
                  background: loading ? "var(--color-text-muted)" : "var(--gradient-primary)",
                  color: "#fff",
                  border: "none",
                  borderRadius: "var(--radius-sm)",
                  fontSize: "15px",
                  fontWeight: 600,
                  cursor: loading ? "not-allowed" : "pointer",
                  transition: "all var(--transition-fast)",
                  boxShadow: loading ? "none" : "0 4px 16px rgba(16, 185, 129, 0.3)",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  gap: "8px",
                }}
              >
                <FiSend size={16} />
                {loading ? "Sending..." : "Send Reset Link"}
              </button>
            </form>
          </>
        ) : (
          /* Success State — user must check their email */
          <div
            className="animate-fade-in"
            style={{ textAlign: "center", padding: "20px 0" }}
          >
            <div
              style={{
                width: "72px",
                height: "72px",
                borderRadius: "50%",
                background: "rgba(16, 185, 129, 0.1)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                margin: "0 auto 24px",
              }}
            >
              <FiMail size={32} color="var(--color-primary)" />
            </div>
            <h2 style={{ fontSize: "22px", fontWeight: 700, marginBottom: "12px" }}>
              Check Your Email
            </h2>
            <p
              style={{
                color: "var(--color-text-muted)",
                fontSize: "14px",
                lineHeight: 1.7,
                marginBottom: "28px",
              }}
            >
              We've sent a password reset link to<br />
              <strong style={{ color: "var(--color-text-primary)" }}>{email}</strong>
              <br />
              <span style={{ fontSize: "13px", marginTop: "8px", display: "inline-block" }}>
                The link will expire in 1 hour.
              </span>
            </p>
            <Link
              to="/"
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "6px",
                padding: "12px 28px",
                background: "var(--gradient-primary)",
                color: "#fff",
                borderRadius: "var(--radius-sm)",
                fontWeight: 600,
                fontSize: "14px",
                boxShadow: "0 4px 16px rgba(16, 185, 129, 0.3)",
              }}
            >
              Back to Login
            </Link>
          </div>
        )}
      </div>
    </div>
  );
};

export default ForgotPassword;