USE [p_adagioRHCRHIrkon]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblHistorialPrimaRiesgo](
	[IDHistorialPrimaRiesgo] [int] IDENTITY(1,1) NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[Anio] [int] NOT NULL,
	[Mes] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Prima] [decimal](21, 10) NOT NULL,
 CONSTRAINT [PK_RHtblHistorialPrimaRiesgo_IDHistorialPrimaRiesgo] PRIMARY KEY CLUSTERED 
(
	[IDHistorialPrimaRiesgo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblHistorialPrimaRiesgo_Anio] ON [RH].[tblHistorialPrimaRiesgo]
(
	[Anio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblHistorialPrimaRiesgo_IDRegPatronal] ON [RH].[tblHistorialPrimaRiesgo]
(
	[IDRegPatronal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_RHtblHistorialPrimaRiesgo_Mes] ON [RH].[tblHistorialPrimaRiesgo]
(
	[Mes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblHistorialPrimaRiesgo]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatRegPatronal_IDRegPatronal] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [RH].[tblHistorialPrimaRiesgo] CHECK CONSTRAINT [FK_RHTblCatRegPatronal_IDRegPatronal]
GO
