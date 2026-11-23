# Running the WebMCP demo

This runs Smart Answers' [WebMCP tools](../webmcp.md) with Chrome's
[example WebMCP extension][], an agent in a side panel that calls the page's
tools.

## Setup

1. Use Chrome 155 or later. In `chrome://flags`, turn on
   `#enable-webmcp-testing`, then restart Chrome.
2. Run Smart Answers with `WEBMCP_ENABLED=1 ./startup.sh --live`, on
   http://localhost:3010. WebMCP needs a secure page, and localhost counts.
3. Clone the [extension][example WebMCP extension]. With Node.js 22.18 or
   later, copy `.env.example` to `.env` and set `MODEL` (as `provider:model`)
   and that provider's API key.
4. Run `npm install` and `npm run server`, then `npm run build` in a second
   terminal.
5. In `chrome://extensions`, turn on Developer mode, click Load unpacked and
   pick the extension's `dist/` folder.
6. Open a flow's start page and click the extension's icon to open the side
   panel, which lists the page's tool.

To run without an API key, turn on Settings > Model > On-device model in the
panel, and `#prompt-api-tool-use` in `chrome://flags`. Its small context suits
task 1 better than task 2.

The Application > WebMCP pane in DevTools logs each call's input and output,
and can run a tool without a model. It's useful to check the tools work before
using the extension.

## Tasks

Start each task on the flow's start page and use the same model for every run.

1. **[Additional commodity code](http://localhost:3010/additional-commodity-code)**:
   "My product is 25% starch or glucose and 5% sucrose, with no milk fat or
   milk protein. What's its additional commodity code?"

   Expect one call to the tool, reaching `commodity_code_result`.

2. **[Statutory sick pay](http://localhost:3010/calculate-statutory-sick-pay)**:
   "My employee was off sick from 5 to 20 January 2026 and told me within 7
   days. They get none of the listed maternity, paternity, adoption,
   bereavement or shared parental pay. They work Monday to Friday every week
   and weren't off sick in the 8 weeks before. I pay them weekly and had paid
   them for at least 8 weeks. They earned £4,000 before deductions between the
   two paydays you'll ask about. How much statutory sick pay do I owe?"

   Expect the agent to ask for the last payday before 5 January 2026, then the
   one on or before 7 November 2025, and nothing else. Answer 2 January 2026
   and 31 October 2025. Expect `entitled_to_sick_pay`.

## Evidence

Record 3 runs of each task.

| Task | Run | Right outcome reached | Tool calls | Time to answer | Questions put to the user |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | | | | |
| 1 | 2 | | | | |
| 1 | 3 | | | | |
| 2 | 1 | | | | |
| 2 | 2 | | | | |
| 2 | 3 | | | | |

The outcome is the `node` in the tool's last reply. Tool calls and questions
put to the user are in the side panel's chat. Time to answer is wall clock
time.

[example WebMCP extension]: https://github.com/GoogleChromeLabs/webmcp-extension
