USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatPuestos](
	[IDPuesto] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescripcionPuesto] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SueldoBase] [money] NULL,
	[TopeSalarial] [money] NULL,
	[IDOcupacion] [int] NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NivelSalarialCompensaciones] [int] NULL,
 CONSTRAINT [PK_tblCatPuestos_IDPuesto] PRIMARY KEY CLUSTERED 
(
	[IDPuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblCatPuestos_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatPuestos]  WITH CHECK ADD  CONSTRAINT [FK_STPSTblCatOcupaciones_RHTblCatPuestos_IDOcupacion] FOREIGN KEY([IDOcupacion])
REFERENCES [STPS].[tblCatOcupaciones] ([IDOcupaciones])
GO
ALTER TABLE [RH].[tblCatPuestos] CHECK CONSTRAINT [FK_STPSTblCatOcupaciones_RHTblCatPuestos_IDOcupacion]
GO
