import asyncio
from playwright.async_api import async_playwright

async def run():
    try:
        async with async_playwright() as p:
            browser = await p.chromium.launch()
            page = await browser.new_page()
            response = await page.goto('https://example.com', timeout=10000)
            if response and response.ok:
                print('✅ Page is up')
            else:
                raise Exception('❌ Page returned non-OK status')
            await browser.close()
    except Exception as e:
        print(e)
        exit(1)

asyncio.run(run())
