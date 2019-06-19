Click
=====

Goal: get Click tests moved to master.
-------------------------------------

1. Start chrome/chromium automatically when test suite runs both locally and on CI.
2. Continue to drive Click development by converting Glacier Point tests. 

Discussion
----------

**Possibly Use Chroxy To Start Chromes/chromiums**: Chroxy provides a way to start chrome servers and provide you with 
proxy's to those chrome servers. You can talk to those servers via the proxies using ChromeRemoteInterface.

Each test would launch a chromium and establish a session via **ChroxyClient.page_session!(%{host: "localhost", port: 1330})**

Or, a pool of chromiums could be initialized and managed with pool boy.

Another idea is to **learn from Wallaby**. Wallaby also starts browsers and manages them with pool boy.

Click Design
------------

**Simpler interface than Wallaby.**

**Attempt to be more elixiry.** Depend on immutable returned values.  

**Get inspiration from jQuery.**: Something[^1] is returned from the initial connect that represents the html node of
the root of the domain. Subsequent requests using this node are scoped by it, until you navigate to a new page by
clicking a link or by the `navigate` function. Functions can operate on one or more of these nodes and return one or
more of these nodes.
 
**Use only css selectors.**

Modules
-------

* **Browser**: browser interactions, higher level than Chrome
* **Chrome**: functions that proxy to ChromeRemoteInterface.RPC
* **Click**: primary interface to click
* **DomNode**: returned from click operations, representing dom nodes in the browser
* **Extra**: enhancements to elixir
* **NodeDescription**: extract information from nodeDescription objects
* **Quad**: functions that operate on quad data structures
* **TestPlug**: test webserver with routes and test html

Definitions
-----------

* [chrome_remote_interface][1]: Elixir Client to the Chrome Debugging Protocol
* [chroxy][2]: Proxy service to mediate access to Chrome that is run in headless mode. Can be used with 
  chrome_remote_interface to control chromes.
* [chroxy_client][3]: Chroxy Chrome Server client for Chroxy which is intended to be used in conjunction with 
  ChromeRemoteInterface.
* [Chrome DevTools Protocol][5]: Allows for tools to instrument, inspect, debug and profile Chromium and Chrome
* [puppeteer][4]: Puppeteer is a Node library which provides a high-level API to control Chrome or Chromium 
  over the DevTools Protocol. From Google.

[1]: https://hex.pm/packages/chrome_remote_interface
[2]: https://hex.pm/packages/chroxy
[3]: https://hex.pm/packages/chroxy_client
[4]: https://github.com/GoogleChrome/puppeteer
[5]: https://chromedevtools.github.io/devtools-protocol/

[^1]: "Something" is currently a DomNode. It could be replaced by something else, possibly a list of selectors and 
      filters.

