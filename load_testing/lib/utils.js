import encoding from 'k6/encoding';


const AUTHORS = [
    'Mr.Smith', 'Jordan Belford', 'Angry Housewife',
    'Gamer', 'Wonder Woman', 'Superman', 'Vegan', 'Web Developer',
    'Iogin', 'Lama Lover'
]

const PRODUCTS = [
    'MMORPG', 'Kettle', 'Gun', 'Pants', 'Tiger puppet', 'Raw Pie',
    'Cloud computing service', 'Shield', 'Lama Socks', 'Ioga carpet',
    'Ferrary', 'New car'
]

const REPLACE_SYMBOL = '$';

const FEEDBACK = [
    {
        evaluation: 10,
        title: `Best ${REPLACE_SYMBOL} ever`,
        text: `Thank you very much for your ${REPLACE_SYMBOL}. Best I ever had`
    },
    {
        evaluation: 9,
        title: `Good ${REPLACE_SYMBOL}`,
        text: `Thank you for your ${REPLACE_SYMBOL}. Just one small note.`
    },
    {
        evaluation: 8,
        title: `Good ${REPLACE_SYMBOL}. But...`,
        text: `Thanks for your ${REPLACE_SYMBOL}. But there are some problem....`
    },
    {
        evaluation: 7,
        title: `Average ${REPLACE_SYMBOL}`,
        text: `Your ${REPLACE_SYMBOL} is cheap and something moderate`
    },
    {
        evaluation: 6,
        title: `You are about to lost your client for your ${REPLACE_SYMBOL}`,
        text: `Your ${REPLACE_SYMBOL} wasn't worked well`
    },
    {
        evaluation: 5,
        title: `Bad ${REPLACE_SYMBOL}`,
        text: `Your ${REPLACE_SYMBOL} broken after first day of usage`
    },
    {
        evaluation: 4,
        title: `I want my money back for your ${REPLACE_SYMBOL}`,
        text: `Your ${REPLACE_SYMBOL} broken after first day of usage. Sales lied to me`
    },
    {
        evaluation: 3,
        title: `I am very angry for your ${REPLACE_SYMBOL}`,
        text: `Your ${REPLACE_SYMBOL} broken after first day of usage. Sales lied to me. I am about to call police`
    },
    {
        evaluation: 2,
        title: `Minus million from the ten for your ${REPLACE_SYMBOL}`,
        text: `Are you kidding me? It's worst ${REPLACE_SYMBOL} I ever have`
    },
    {
        evaluation: 1,
        title: `I call police ${REPLACE_SYMBOL}`,
        text: `Seriously ${REPLACE_SYMBOL} I mean it.`
    }
]

const DEFAULT_HOST = 'localhost';
const DEFAULT_PORT = 4000;

const BASIC_PRODUCT_URL = "https://amaczon.com/sale"

const PERMITTED_CUSTOMERS = ["customer_1", "customer_2", "customer_3", "customer_4", "customer_5"];
const CUSTOMER_TOKEN = "secret_token";

export function getFeedbackContent(feedbackObject, productName) {
    const { evaluation, title, text } = feedbackObject;
    return {
        evaluation,
        title: title.replace(/${REPLACE_SYMBOL}/g, productName),
        text: text.replace(/${REPLACE_SYMBOL}/g, productName)
    }
}

export function getProductUrl(productName) {
    const alias = `${productName}`.replace(/\s/g, '_');
    return `${BASIC_PRODUCT_URL}/${alias}`;
}

export function getEnvironmentHost() {
    const host = __ENV.HOST;
    return (host ? host : DEFAULT_HOST);
}

export function getEnvironmentPort() {
    const port = __ENV.PORT;
    return (port ? port : DEFAULT_PORT);
}

export function getBasicAuthentication(customerId) {
    const encoded = encoding.b64encode(`${customerId}:${CUSTOMER_TOKEN}`);
    return `Basic ${encoded}`;
}

export function getRandomNumber(maxNumber) {
    return Math.floor(Math.random() * maxNumber);
}

export function randomArrayElement(array) {
    return array[getRandomNumber(array.length)]
}

export function getRandomAuthor() {
    return randomArrayElement(AUTHORS)
}

export function getRandomProduct() {
    return randomArrayElement(PRODUCTS)
}

export function getRandomCustomer() {
    return randomArrayElement(PERMITTED_CUSTOMERS)
}

export function getRandomFeedback() {
    return randomArrayElement(FEEDBACK)
}
