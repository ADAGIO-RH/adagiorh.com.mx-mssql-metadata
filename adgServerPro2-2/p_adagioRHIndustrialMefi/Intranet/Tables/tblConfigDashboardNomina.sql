USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Intranet].[tblConfigDashboardNomina](
	[IDConfigDashboardNomina] [int] NOT NULL,
	[BotonLabel] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Filtro] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDPais] [int] NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_IntranetTblConfigDashboardNomina_IDConfigDashboardNomina] PRIMARY KEY CLUSTERED 
(
	[IDConfigDashboardNomina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Intranet].[tblConfigDashboardNomina]  WITH CHECK ADD  CONSTRAINT [Fk_IntranetTblConfigDashboardNomina_SatTblCatPaises_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Intranet].[tblConfigDashboardNomina] CHECK CONSTRAINT [Fk_IntranetTblConfigDashboardNomina_SatTblCatPaises_IDPais]
GO
ALTER TABLE [Intranet].[tblConfigDashboardNomina]  WITH CHECK ADD  CONSTRAINT [Chk_IntranetTblConfigDashboardNomina_Traduccion_is_json] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [Intranet].[tblConfigDashboardNomina] CHECK CONSTRAINT [Chk_IntranetTblConfigDashboardNomina_Traduccion_is_json]
GO
