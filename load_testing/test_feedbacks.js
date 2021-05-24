import http from "k6/http"
import {
    getEnvironmentHost,
    getEnvironmentPort,
    getBasicAuthentication,
    getRandomAuthor,
    getRandomProduct,
    getRandomCustomer,
    getRandomFeedback,
    getFeedbackContent,
    getProductUrl
} from './lib/utils.js'

const host = getEnvironmentHost();
const port = getEnvironmentPort();

function sendRequest() {
    const customerId = getRandomCustomer();
    const product = getRandomProduct();
    const author = getRandomAuthor();
    const feedback = getRandomFeedback();
    const productUrl = getProductUrl(product);

    const { evaluation, title, text } = getFeedbackContent(feedback, product);

    const customerFeedback = {
        evaluation,
        title,
        text,
        author,
        product_url: productUrl
    };

    const basicAuth = getBasicAuthentication(customerId);

    const headers = {
        accept: 'application/json',
        contentType: 'application/json',
        authorization: basicAuth
    }

    const requestUrl = `http://${host}:${port}/api/customer_feedback`;
    const response = http.post(requestUrl, customerFeedback, { headers });
    return response;
}

// To run test install k6 and simply run its file with appropriate options from the root project folder
// k6 run --vus 300 --rps 200 --duration 300s load_testing/test_catchup.js
// Where:
// --rps - requests per second number. By specification it must be at most 5000
// --duration - could be any. Must specify measure - minutes(m) seconds(s). For example 5s, 120s, 1m, 1m30s
// --vus - users count. Basically does not matter. But should be more than 5 because in that
// case number of requests per second must be closer to specified in --rps number

export default function() {
    sendRequest();
    return true;
}
