USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Resguardo].[tblCatCasetas](
	[IDCaseta] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Activa] [bit] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_ResguardoTblCatCasetas_IDCaseta] PRIMARY KEY CLUSTERED 
(
	[IDCaseta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Resguardo].[tblCatCasetas] ADD  CONSTRAINT [D_ResguardoTblCatCasetas_Activa]  DEFAULT ((1)) FOR [Activa]
GO
ALTER TABLE [Resguardo].[tblCatCasetas] ADD  CONSTRAINT [D_ResguardoTblCatCasetas_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
