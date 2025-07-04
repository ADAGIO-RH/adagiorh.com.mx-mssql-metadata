USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblCatCesantiaVejezPatronalDetalle](
	[IDCesantiaVejezPatronalDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDCesantiaVejezPatronal] [int] NOT NULL,
	[MinimoGeneral] [decimal](18, 2) NULL,
	[MaximoGeneral] [decimal](18, 2) NULL,
	[MinimoFronterizo] [decimal](18, 2) NULL,
	[MaximoFronterizo] [decimal](18, 2) NULL,
	[CuotaPatronal] [decimal](18, 6) NULL,
	[Desde] [decimal](18, 2) NULL,
	[Hasta] [decimal](18, 2) NULL,
 CONSTRAINT [PK_IMSStblCatCesantiaVejezPatronalDetalle_IDCesantiaVejezPatronalDetalle] PRIMARY KEY CLUSTERED 
(
	[IDCesantiaVejezPatronalDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [IMSS].[tblCatCesantiaVejezPatronalDetalle]  WITH CHECK ADD  CONSTRAINT [FK_IMSStblCatCesantiaVejezPatronal_IMSStblCatCesantiaVejezPatronalDetalle_IDCesantiaVejezPatronal] FOREIGN KEY([IDCesantiaVejezPatronal])
REFERENCES [IMSS].[tblCatCesantiaVejezPatronal] ([IDCesantiaVejezPatronal])
GO
ALTER TABLE [IMSS].[tblCatCesantiaVejezPatronalDetalle] CHECK CONSTRAINT [FK_IMSStblCatCesantiaVejezPatronal_IMSStblCatCesantiaVejezPatronalDetalle_IDCesantiaVejezPatronal]
GO
