<?php
// Get server's public IP address
$server_ip = $_SERVER['SERVER_ADDR'] ?? gethostbyname(gethostname());

// Use an external API to get location info
$details = @json_decode(file_get_contents("https://ipapi.co/{$server_ip}/json/"));
?>

<!DOCTYPE html>
<html>
  <head>
    <title>Cloud Programming</title>
  </head>
  <body>
    <h1>Hello World!</h1>

    <button onclick="measureSelfLatency()">Check Latency</button>
    <p id="latency">Click the button to check latency to this page.</p>

    <p id="country"></p>

    <h2>This Website Is Hosted In:</h2>
    <p>
      Country: <?php echo $details->country_name ?? 'Unavailable'; ?><br>
      Region: <?php echo $details->region ?? 'Unavailable'; ?><br>
      City: <?php echo $details->city ?? 'Unavailable'; ?>
    </p>

    <script>
      async function measureSelfLatency() {
        const endpoint = window.location.href;
        const start = performance.now();

        try {
          await fetch(endpoint, { method: 'HEAD', cache: 'no-store' });
          const end = performance.now();
          const latency = end - start;
          document.getElementById("latency").textContent = `Latency to this site: ${latency.toFixed(2)} ms`;
        } catch (err) {
          document.getElementById("latency").textContent = `Error checking latency: ${err}`;
        }
      }

      fetch('https://ipapi.co/json/')
        .then(response => response.json())
        .then(data => {
          document.getElementById('country').textContent = `You are visiting from: ${data.country_name}`;
        })
        .catch(error => {
          document.getElementById('country').textContent = 'Unable to determine country.';
          console.error('Error fetching IP data:', error);
        });
    </script>
  </body>
</html>