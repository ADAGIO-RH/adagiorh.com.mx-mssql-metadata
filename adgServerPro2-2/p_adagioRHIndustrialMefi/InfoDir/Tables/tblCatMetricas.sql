USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblCatMetricas](
	[IDMetrica] [int] IDENTITY(1,1) NOT NULL,
	[IDAplicacion] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConfiguracionFiltros] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreProcedure] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Background] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Color] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaDe] [date] NULL,
	[FechaHasta] [date] NULL,
	[IDPeriodo] [int] NULL,
	[IsKpi] [bit] NULL,
	[Objetivo] [decimal](18, 2) NULL,
 CONSTRAINT [Pk_InfoDirtblCatMetricas_IDMetrica] PRIMARY KEY CLUSTERED 
(
	[IDMetrica] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [InfoDir].[tblCatMetricas]  WITH CHECK ADD  CONSTRAINT [FK_InfoDirtblCatMetricas_InfoDirtblCatPeriodos_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [InfoDir].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [InfoDir].[tblCatMetricas] CHECK CONSTRAINT [FK_InfoDirtblCatMetricas_InfoDirtblCatPeriodos_IDPeriodo]
GO
