USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrutamiento].[tblCatTiposProcesos](
	[IDCatTipoProceso] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Prefijo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[StoreProcedureComplete] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TemplateUser] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [U_EnrutamientotblCatTiposProcesos_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
