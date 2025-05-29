---
title: "MiNAA-WebApp: A Web-Based Tool for the Visualization and Analysis of Microbiome Networks"
authors:
  - name: Qiyao Yang
    affiliation: "1,2,3"
  - name: Rosa Aghdam
    affiliation: 2
  - name: Reed Nelson
    affiliation: 2    
  - name: Claudia Solis-Lemus
    corresponding: true
    email: solislemus@wisc.edu
    affiliation: "2,4"
affiliations:
  - name: Department of Computer Science, University of Wisconsin-Madison, Madison, WI, United States of America
    index: 1
  - name: Wisconsin Institute for Discovery, University of Wisconsin-Madison, Madison, WI, United States of America
    index: 2
  - name: Department of  Statistics, University of Wisconsin-Madison, Madison, WI, United States of America
    index: 3
  - name: Department of Plant Pathology, University of Wisconsin-Madison, Madison, WI, United States of America
    index: 4
date: 29 May 2025
bibliography: paper.bib
---

# Summary
Microbial networks, representing microbes as nodes and their interactions as edges, are crucial for understanding community dynamics in various environments. Analyzing microbiome networks is crucial for identifying keystone taxa that play central roles in maintaining microbial community structure and function, assessing how environmental changes such as pollution, climate shifts, or land use affect microbial dynamics, tracking disease progression by revealing alterations in microbial interactions over time, and predicting microbial community responses to interventions such as antibiotics, probiotics, or changes in diet and habitat. The complexity of microbial interactions necessitates the use of computational tools such as the `MiNAA`, available at [https://minaa.wid.wisc.edu](https://minaa.wid.wisc.edu), which enhances the accessibility of the Microbiome Network Alignment Algorithm (`MiNAA`). This tool allows researchers to align microbial networks and explore ecological relationships and community dynamics without extensive computational skills. Originally, `MiNAA`'s command-line interface limited its usability for those without programming backgrounds. The web-based `MiNAA` addresses this shortcoming by offering an intuitive interface with visualization tools, allowing easy exploration and analysis of microbial networks. The web app is designed for microbiome networks but also applicable to other biological networks, broadening its use in computational biology and making network-based research accessible to a wider audience.


# Statement of need
By aligning microbiome networks obtained under different settings (e.g., different fumigation treatments in soil), the Microbiome Network Alignment Algorithm (`MiNAA`) [@Nelson2024] allows scientists to identify key microbial taxa that differ across treatments, as well as key taxa that serve similar functions in different communities. The `MiNAA` algorithm builds on the GRAph ALigner (`GRAAL`) algorithm [@kuchaiev2010topological], the Hungarian algorithm [@kuhn1955hungarian; @Pilgrim1995], and the Graphlet Degree Vector (GDV) method [@prvzulj2007biological] to characterize nodes by local connectivity, capturing both direct connections and broader structural roles. The `MiNAA-WebApp` addresses the challenge of making advanced network analysis tools accessible to non-technical users to allow understanding of ecological dynamics. It provides a user-friendly, web-based platform that allows scientists to incorporate computational techniques into research and lowers barriers for exploring complex datasets. The application’s interactive visualizations and intuitive design support hands-on learning and make abstract concepts tangible, suitable for classroom use and independent study. It also supports interdisciplinary collaboration, enabling researchers from various fields to engage with the tool without programming expertise. The open-source nature of the `MiNAA-WebApp` allows for customization to meet specific teaching or research needs, democratizing access to advanced computational methods and promoting broader adoption across disciplines.

