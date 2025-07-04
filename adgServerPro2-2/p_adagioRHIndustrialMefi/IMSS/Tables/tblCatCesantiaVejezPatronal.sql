USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblCatCesantiaVejezPatronal](
	[IDCesantiaVejezPatronal] [int] IDENTITY(1,1) NOT NULL,
	[FechaInicial] [date] NOT NULL,
	[FechaFinal] [date] NOT NULL,
	[Descripcion]  AS ((('CESANTIA Y VEJEZ PATRONAL DESDE '+format([FechaInicial],'dd-MM-yyyy'))+' al ')+format([FechaFinal],'dd-MM-yyyy')),
 CONSTRAINT [PK_IMSStblCatCesantiaVejezPatronal_IDCesantiaVejezPatronal] PRIMARY KEY CLUSTERED 
(
	[IDCesantiaVejezPatronal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
