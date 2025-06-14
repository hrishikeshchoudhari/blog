defmodule Mix.Tasks.Blog.TestEmail do
  @moduledoc """
  Tests email configuration by sending a test email.
  
  Usage:
    mix blog.test_email recipient@example.com
  """
  
  use Mix.Task
  import Swoosh.Email
  
  @shortdoc "Sends a test email to verify email configuration"
  
  def run([email]) do
    Mix.Task.run("app.start")
    
    test_email = 
      new()
      |> to(email)
      |> from({"Blog Test", "test@example.com"})
      |> subject("Test Email from Blog")
      |> text_body("This is a test email to verify your email configuration is working correctly.")
      |> html_body("""
      <h2>Test Email</h2>
      <p>This is a test email to verify your email configuration is working correctly.</p>
      <p>If you received this email, your Postmark integration is working!</p>
      <hr>
      <p><small>Sent at: #{DateTime.utc_now()}</small></p>
      """)
    
    case Blog.Mailer.deliver(test_email) do
      {:ok, _metadata} ->
        Mix.shell().info("✅ Email sent successfully to #{email}")
        Mix.shell().info("Check your inbox!")
        
      {:error, reason} ->
        Mix.shell().error("❌ Failed to send email:")
        Mix.shell().error(inspect(reason))
    end
  end
  
  def run(_) do
    Mix.shell().error("Usage: mix blog.test_email recipient@example.com")
  end
end