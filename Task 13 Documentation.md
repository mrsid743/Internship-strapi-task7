# **Documentation: Unleash Feature Flag Integration in a Local React Application**

This document provides a comprehensive guide on what Unleash is and how to integrate it into a local React-based application for effective feature management.

## **1\. What is Unleash Used For? 💡**

**Unleash** is an open-source **feature flag** (or feature toggle) system. It gives you a new level of control over your application's features, effectively decoupling code deployment from feature releases.

Think of it as a set of remote-controlled light switches for the features in your app. You can deploy new code to production with a feature's "switch" turned off, and then turn it on for specific users or a percentage of users whenever you're ready—all without a new deployment.

### **Key Use Cases:**

* **Trunk-Based Development:** Developers can merge unfinished features into the main branch, keeping them hidden behind a flag until they are complete.  
* **Gradual Rollouts (Canary Releases):** Safely release a new feature to a small subset of users (e.g., 1% of users, or only internal employees) to monitor its performance and stability before rolling it out to everyone.  
* **A/B Testing:** Show different versions of a feature to different user segments to test which one performs better.  
* **Kill Switches:** Instantly disable a buggy or poorly performing feature in production without needing to roll back the entire deployment. This is a powerful tool for incident management.  
* **Targeted Releases:** Enable features only for users who meet certain criteria (e.g., users in a specific country, on a premium plan, or using a specific browser).

## **2\. How to Set It Up for a Local React Application 🚀**

This guide will walk you through setting up an Unleash server locally using Docker and integrating the React SDK into your application.

### **Prerequisites**

* **Node.js and npm/yarn** installed.  
* A running **React application** (e.g., created with Create React App or Vite).  
* **Docker Desktop** installed and running on your machine.

### **Step 1: Run the Unleash Server Locally**

The easiest way to run Unleash for local development is by using its official Docker image.

1. Open your terminal or command prompt.  
2. Pull and run the Unleash Docker container with the following command:  
   docker run \-p 4242:4242 unleashorg/unleash-server

   This command downloads the Unleash server image and starts it, mapping the container's port 4242 to your local machine's port 4242\.  
3. **Verify the Server:** Open your web browser and navigate to http://localhost:4242. You should see the Unleash login screen.  
   * **Default Username:** admin  
   * **Default Password:** unleash4all

### **Step 2: Create Your First Feature Flag**

Now, let's create a feature flag in the Unleash UI that we can control from our React app.

1. Log in to your local Unleash instance at http://localhost:4242.  
2. In the dashboard, click the **"New feature flag"** button.  
3. Fill in the details:  
   * **Name:** my-cool-feature (this is the name you'll use in your code).  
   * **Type:** Select "Release".  
   * **Description (Optional):** "Toggles the new experimental dashboard."  
4. Click **"Create feature flag"**.  
5. You'll be taken to the flag's configuration page. Under the **"development"** environment, find the "Standard" activation strategy and **make sure the toggle switch is turned ON**. This enables the feature.

### **Step 3: Integrate the Unleash SDK into Your React App**

Now we'll connect our React application to the Unleash server.

1. **Install the Unleash React SDK:** In your React project's directory, run the following command:  
   \# Using npm  
   npm install @unleash/proxy-client-react

   \# Using yarn  
   yarn add @unleash/proxy-client-react

2. **Create an API Token in Unleash:** Your application needs an API key to securely communicate with the Unleash server.  
   * In the Unleash UI, go to **Admin** \-\> **API access**.  
   * Click **"New API token"**.  
   * **Username:** Give it a descriptive name like react-local-app.  
   * **Type:** Select **Client-side SDK**.  
   * **Environment:** Select development.  
   * Click **"Create token"**.  
   * **✅ IMPORTANT:** Copy the generated token immediately. You won't be able to see it again.  
3. **Configure the FlagProvider:** The SDK uses a React Context Provider to make flags available throughout your app. You need to wrap your root component (usually in src/index.js or src/main.jsx) with the FlagProvider.  
   Update your src/index.js (or equivalent entry file) like this:  
   import React from 'react';  
   import ReactDOM from 'react-dom/client';  
   import App from './App';  
   import { FlagProvider } from '@unleash/proxy-client-react';

   // Unleash configuration object  
   const config \= {  
     url: 'http://localhost:4242/api/frontend', // URL of the Unleash server's frontend API  
     clientKey: 'YOUR\_CLIENT\_SIDE\_API\_TOKEN',    // The token you created in the previous step  
     appName: 'my-react-app',                    // A name for your application  
     environment: 'development'                  // The environment you want to connect to  
   };

   const root \= ReactDOM.createRoot(document.getElementById('root'));  
   root.render(  
     \<React.StrictMode\>  
       \<FlagProvider config={config}\>  
         \<App /\>  
       \</FlagProvider\>  
     \</React.StrictMode\>  
   );

   **Note:** Replace 'YOUR\_CLIENT\_SIDE\_API\_TOKEN' with the actual token you copied from the Unleash UI.

### **Step 4: Use the Feature Flag in a Component**

You can now check the status of any feature flag within your components using the useFlag hook.

Here’s an example of how to modify your src/App.js to conditionally render a component based on the my-cool-feature flag:

import './App.css';  
import { useFlag } from '@unleash/proxy-client-react';

function App() {  
  // Use the useFlag hook to check the status of your feature flag  
  const isMyCoolFeatureEnabled \= useFlag('my-cool-feature');

  return (  
    \<div className="App"\>  
      \<header className="App-header"\>  
        \<h1\>Welcome to My React App\</h1\>

        {isMyCoolFeatureEnabled ? (  
          \<div style={{ padding: '20px', backgroundColor: 'green', borderRadius: '8px', marginTop: '20px' }}\>  
            \<h2\>🚀 The New Cool Feature is ON\! 🚀\</h2\>  
            \<p\>You are seeing this because the 'my-cool-feature' flag is enabled.\</p\>  
          \</div\>  
        ) : (  
          \<div style={{ padding: '20px', backgroundColor: 'red', borderRadius: '8px', marginTop: '20px' }}\>  
            \<h2\>🚧 The New Feature is OFF 🚧\</h2\>  
            \<p\>This is the old, boring content.\</p\>  
          \</div\>  
        )}  
      \</header\>  
    \</div\>  
  );  
}

export default App;

### **Step 5: Test the Integration**

You have successfully integrated Unleash into your local React application\!

Now, you can go back to the Unleash UI at http://localhost:4242 and toggle the my-cool-feature flag **OFF** and **ON**. When you refresh your React application, you will see the content change instantly without requiring any code changes or application restarts. This demonstrates the power of separating feature releases from code deployments.