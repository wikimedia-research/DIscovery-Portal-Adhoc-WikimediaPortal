traffic <- readr::read_tsv("data/portals-traffic.tsv")
head(traffic)

options(scipen = 500)

library(ggplot2)
library(magrittr)

traffic %>%
  ggplot(aes(x = date, y = pageviews, color = portal)) +
  geom_line(size = 1.25) +
  scale_y_log10("Pageviews",
                breaks = c(1e4, 1e5, 1e6, 1e7),
                labels = c("10K", "100K", "1M", "10M")) +
  ggtitle("Page views for wikimedia.org vs. wikipedia.org") +
  geom_text(data = rbind(head(traffic, 2), tail(traffic, 2)),
            aes(x = date, y = pageviews,
                label = polloi::compress(pageviews, 1)),
            nudge_y = 0.1) +
  scale_color_brewer("Portal", type = "qual", palette = "Set1") +
  ggthemes::theme_tufte(base_family = "Gill Sans", base_size = 14) +
  theme(panel.grid = element_line(color = "black"),
        legend.position = "bottom")

traffic %>%
  dplyr::group_by(date) %>%
  dplyr::mutate(proportion = pageviews/sum(pageviews)) %>%
  ggplot(aes(x = date, y = pageviews, fill = portal)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_y_continuous("Proportion of Traffic to Portals", labels = scales::percent_format()) +
  ggtitle("Page views for wikimedia.org vs. wikipedia.org") +
  scale_fill_brewer("Portal", type = "qual", palette = "Set1") +
  ggthemes::theme_tufte(base_family = "Gill Sans", base_size = 14) +
  theme(panel.grid = element_line(color = "black"),
        legend.position = "bottom")
