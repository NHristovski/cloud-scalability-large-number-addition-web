package scalability.cloud.largenumberadditionweb.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import scalability.cloud.largenumberadditionweb.message.SumResponse;

import java.math.BigInteger;
import java.time.Instant;

@RestController
public class LargeNumberAdditionController {

    private static final Logger logger = LoggerFactory.getLogger(LargeNumberAdditionController.class);

    @GetMapping("/sum")
    public ResponseEntity<SumResponse> sumConsecutiveNumbers(@RequestParam BigInteger start, @RequestParam long limit) {
        Instant timeStart = Instant.now();
        logger.info("Received Sum Request. Start: " + start + " , limit: " + limit);

        long counter = 0;

        BigInteger sum = BigInteger.ZERO;
        BigInteger currentNmber = start;

        while (counter < limit) {

            sum = sum.add(currentNmber);
            currentNmber = currentNmber.add(BigInteger.ONE);

            counter++;
        }

        double minutesPassed = (Instant.now().getEpochSecond() - timeStart.getEpochSecond()) / 60.0;

        logger.info("Next {} numbers were added, sum is: [ {} ] . Processing was running for {} minutes",
                limit, sum, String.format("%.2f", minutesPassed));

        return ResponseEntity.ok(new SumResponse(sum));
    }

    @GetMapping("/ping")
    public String ping() {
        logger.info("Got ping request, returning UP.");
        return "UP";
    }
}
