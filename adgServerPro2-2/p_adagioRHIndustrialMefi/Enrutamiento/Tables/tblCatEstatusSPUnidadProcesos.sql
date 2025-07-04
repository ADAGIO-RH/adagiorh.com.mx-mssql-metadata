USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrutamiento].[tblCatEstatusSPUnidadProcesos](
	[IDCatEstatusSPUnidadProcesos] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCatTipoProceso] [int] NOT NULL,
	[IDEstatus] [int] NULL,
	[NameSP] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_tblCatEstatusSPUnidadProcesos_IDCatEstatusSPUnidadProcesos] PRIMARY KEY CLUSTERED 
(
	[IDCatEstatusSPUnidadProcesos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
