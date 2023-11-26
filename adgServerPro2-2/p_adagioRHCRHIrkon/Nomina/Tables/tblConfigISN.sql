USE [p_adagioRHCRHIrkon]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblConfigISN](
	[IDConfigISN] [int] NOT NULL,
	[IDEstado] [int] NOT NULL,
	[Porcentaje] [decimal](10, 4) NULL,
	[IDConceptos] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_NominaTblConfigISN] PRIMARY KEY CLUSTERED 
(
	[IDConfigISN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_nominatblConfigISN_IDEmpleado] ON [Nomina].[tblConfigISN]
(
	[IDEstado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblConfigISN]  WITH CHECK ADD  CONSTRAINT [FK_STPSTblEstado_Nomina_NominaTblConfigISN_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [STPS].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [Nomina].[tblConfigISN] CHECK CONSTRAINT [FK_STPSTblEstado_Nomina_NominaTblConfigISN_IDEstado]
GO
